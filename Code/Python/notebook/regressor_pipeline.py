import pandas as pd
import numpy as np
from scipy import interp
from sklearn.preprocessing import OneHotEncoder, LabelEncoder, LabelBinarizer, Imputer
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.pipeline import Pipeline, FeatureUnion
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.metrics import *
import sklearn.multiclass
from itertools import cycle
import matplotlib
import matplotlib.pyplot as plt


########################################################################################################
# This script set up machine learning pipieline for grid search of RandomForestRegressor on 5-fold CV
########################################################################################################


unseen_label = "__New__"
seed = 200

class CustomLabelBinarizer(BaseEstimator, TransformerMixin):
    def __init__(self):
        self.le = LabelEncoder()
        self.lb = LabelBinarizer()
        self.seen_labels = set()
        
    def fit(self, x, y=None,**fit_params):
        self.seen_labels = set(x)
        self.seen_labels.add(unseen_label)
        
        # add "unseen" to X
        x_new = list(x)
        x_new.append(unseen_label)

        label_encoded = self.le.fit_transform(x_new)
        self.lb.fit(label_encoded)
        return self
    
    def transform(self, x):
        x_new = list(map(lambda label: label if label in self.seen_labels else unseen_label, list(x)))
        label_encoded = self.le.transform(x_new)
        return self.lb.transform(label_encoded)
    
    
class ItemSelector(BaseEstimator, TransformerMixin):
    def __init__(self, key):
        self.key = key

    def fit(self, x, y=None):
        return self

    def transform(self, df):
        return df[self.key]

    
class MultiItemSelector(BaseEstimator, TransformerMixin):
    def __init__(self, key_list):
        self.key_list = key_list

    def fit(self, x, y=None):
        return self

    def transform(self, df):
        return df[self.key_list]
    
    
def descretize(x, cutoff1, cutoff2):
    if x < cutoff1:
        return 0
    elif x < cutoff2:
        return 1
    else: 
        return 2

    
def evaluate_regressor(y_true, y_pred):
    print("R2 Score: ", r2_score(y_true, y_pred))
    print("Mean Absolute Error: ", mean_absolute_error(y_true, y_pred))

    
def evaluate_classifier(y_true, y_pred):
    # compute accuracy
    print("Accuracy:", accuracy_score(y_true, y_pred))
    
    # compute auc for each class respectively
    fpr = dict()
    tpr = dict()
    roc_auc = dict()
    for i in range(3):
        fpr[i], tpr[i], _ = roc_curve(y_true[:, i], y_pred[:, i])
        roc_auc[i] = auc(fpr[i], tpr[i])
        print("ROC AUC for Class ", i, ": ", roc_auc[i])
    
    # compute micro-average auc
    fpr["micro"], tpr["micro"], _ = roc_curve(np.array(y_true).ravel(), y_pred.ravel())
    roc_auc["micro"] = auc(fpr["micro"], tpr["micro"])
    print("Micro-average ROC AUC: ", roc_auc["micro"])

   # compute macro-average auc
    n_classes = 3
    all_fpr = np.unique(np.concatenate([fpr[i] for i in range(n_classes)]))
    mean_tpr = np.zeros_like(all_fpr)
    for i in range(n_classes):
        mean_tpr += interp(all_fpr, fpr[i], tpr[i])
    mean_tpr /= n_classes
    fpr["macro"] = all_fpr
    tpr["macro"] = mean_tpr
    roc_auc["macro"] = auc(fpr["macro"], tpr["macro"])
    print("Macro-average ROC AUC: ", roc_auc["macro"])

    
def fit_gridsearch_pipeline(df, numerical_features, metric):
    df_dead = df[(df.hospital_expire_flag==1) & (df.hosp_deathtime_hours>=0)]
    train_cv_df = df_dead.sample(frac=0.8,random_state=seed)
    test_df = df_dead.drop(train_cv_df.index)
    
    # define the machine learning pipeline
    discrete_pipeline = Pipeline([
        ("feature_union", FeatureUnion(
            transformer_list=[
                # categorical pipeline
                ('ethnicity', Pipeline([
                    ("selector", ItemSelector(key='ethnicity')),
                    ("binarizer", CustomLabelBinarizer())
                ])),            
                ("gender", Pipeline([
                    ("selector", ItemSelector(key='gender')),
                    ("binarizer", CustomLabelBinarizer())
                ])),
                ("admission_type", Pipeline([
                    ("selector", ItemSelector(key='admission_type')),
                    ("binarizer", CustomLabelBinarizer())
                ])),
                # numerical pipeline
                ("numerical", Pipeline([
                    ("selector", MultiItemSelector(key_list=numerical_features)),
                    ("imputer", Imputer(strategy="median",axis=0)),
                ]))
            ]
        )),
        ("algorithm", RandomForestRegressor(random_state=0, n_jobs=-1))
    ])

    # define the parameter grid
    parameters = {'algorithm__n_estimators': [100, 250, 500],
                  'algorithm__max_features': ["auto", "sqrt", "log2"],
                  "algorithm__max_depth": [5, 10, 30],
                  "algorithm__bootstrap": [True, False]}

    grid_search = GridSearchCV(discrete_pipeline, parameters, n_jobs=-1, verbose=1, refit=True, cv=5, scoring=metric)
    grid_search.fit(train_cv_df, train_cv_df.hosp_deathtime_hours)

    print("\nGrid Search Best parameters set :")
    print(grid_search.best_params_)
    print("\nBest score: %0.3f" % grid_search.best_score_)
    
    # evaluate model performance on training set
    print("\nEvaluation on Training Set (80%) :")
    train_actual = train_cv_df.hosp_deathtime_hours
    train_pred = grid_search.predict(train_cv_df)
    
    cutoff1 = 24
    cutoff2 = 24*7
    train_actual_label = [descretize(x, cutoff1, cutoff2) for x in train_actual]
    train_pred_label = [descretize(x, cutoff1, cutoff2) for x in train_pred]
    
    lb = LabelBinarizer()
    train_actual_label = lb.fit_transform(train_actual_label)
    train_pred_label = lb.transform(train_pred_label)

    evaluate_regressor(train_actual, train_pred)
    evaluate_classifier(train_actual_label, train_pred_label)
    
    # evaluate model performance on test set
    print("\nEvaluation on Test Set (20%) :")
    test_actual = test_df.hosp_deathtime_hours
    test_pred = grid_search.predict(test_df)
    
    # convert numerical values of predicted outcome to multi-class labels 
    cutoff1 = 24
    cutoff2 = 24*7
    test_actual_label = [descretize(x, cutoff1, cutoff2) for x in test_actual]
    test_pred_label = [descretize(x, cutoff1, cutoff2) for x in test_pred]
    
    # convert multi-class labels to binary label
    test_actual_label = lb.transform(test_actual_label)
    test_pred_label = lb.transform(test_pred_label)
    
    evaluate_regressor(test_actual, test_pred)
    evaluate_classifier(test_actual_label, test_pred_label)
 
    return grid_search

import pandas as pd

def read_excel_data(filepath):
    data_list = pd.read_excel(filepath)
    return data_list
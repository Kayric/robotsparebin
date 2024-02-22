import pandas as pd
def read_csv_file(filename):
        df = pd.read_csv(filename)
        return df
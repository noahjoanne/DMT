from pandas import read_csv
from pandas import DataFrame
import pandas as pd
import matplotlib.pyplot as plt

df = read_csv('data/dataset_mood_smartphone.csv', header=0, index_col=0,parse_dates=True, squeeze=True)

dataframe = DataFrame()



# Print column names
print('Column names: ', df.columns)


# Print variable names
print('Variable names: ', df.variable.unique())


# Print patient IDs
print('Patient IDs: ', df.id.unique())


# for patient_id in df.id.unique():
# 	sample = df.loc[df['id'] == patient_id]
# 	print(sample.shape)



#### EXPERIMENT WITH FIRST PATIENT ###
## id : AS14.01

df1 = df.loc[df['id'] == 'AS14.01']

print('Patient 1 df shape: ', df1.shape)

## only use mood variable ##

df1 = df1.loc[df1['variable'] == 'mood']

print('Patient 1 df shape (only mood variable): ', df1.shape)


## drop all columns except mood_value and time

df1 = df1[['time', 'value']]


## average mood values per day ###

df1['date'] = pd.to_datetime(df1['time']).dt.date
df1['freq'] = df1.groupby('date')['date'].transform('count')
print(df1)


df2 = DataFrame()
df2['date'] = df1['date'].unique()
df2['count'] = [sum([1 for date in df1['date'] if date == val]) for val in df2['date']]
df2['agg_mood'] = [0 for x in df2['date']]

for index, row in df1.iterrows():
	date = row['date']
	val = row['value']
	row_idx = df2.index[df2['date'] == date]
	df2.loc[row_idx, 'agg_mood'] += val

df2['mood_avg'] = df2['agg_mood'] / df2['count']
	
print(df2)

df3 = DataFrame()
df3['date'] = df2['date']
df3['val'] = df2['mood_avg']

df3.plot.line()

plt.show()


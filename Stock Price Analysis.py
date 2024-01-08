#!/usr/bin/env python
# coding: utf-8

# In[14]:


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt 
import seaborn as sns
import os
import glob 


# In[6]:


files = os.listdir(r"C:\Users\Patel_Shiv\Downloads\S&P_resources\individual_stocks_5yr")


# In[7]:


files_csv = [file for file in files if '.csv' in file]


# In[9]:


files_csv


# In[11]:


df = pd.DataFrame()
path = r"C:\Users\Patel_Shiv\Downloads\S&P_resources\individual_stocks_5yr"
for file in files_csv:
    stock_df = pd.read_csv(path + '/' + file, encoding='iso-8859-1', on_bad_lines='skip')
    
    df = pd.concat([df, stock_df], ignore_index=True)


# In[12]:


df.shape


# In[13]:


df[df.duplicated()].shape


# In[ ]:





# In[15]:


glob.glob(r"C:\Users\Patel_Shiv\Downloads\S&P_resources\individual_stocks_5yr/*csv")


# In[16]:


company_list = [
    r'C:\\Users\\Patel_Shiv\\Downloads\\S&P_resources\\individual_stocks_5yr\\AAPL_data.csv',
    r'C:\\Users\\Patel_Shiv\\Downloads\\S&P_resources\\individual_stocks_5yr\\AMZN_data.csv',
    r'C:\\Users\\Patel_Shiv\\Downloads\\S&P_resources\\individual_stocks_5yr\\GOOG_data.csv',
    r'C:\\Users\\Patel_Shiv\\Downloads\\S&P_resources\\individual_stocks_5yr\\MSFT_data.csv'
]


# In[21]:


import warnings
from warnings import filterwarnings
filterwarnings('ignore')


all_data = pd.DataFrame()


for file in company_list:
    current_df = pd.read_csv(file)
    
    all_data = all_data._append(current_df, ignore_index= True)


# In[22]:


all_data.shape


# In[ ]:





# In[24]:


all_data['date'] = pd.to_datetime(all_data['date'])


# In[26]:


stocks = all_data['Name'].unique()


# In[ ]:





# In[28]:


plt.figure(figsize=(20,12))


for index, stock in enumerate(stocks, 1):
    plt.subplot(2,2, index)
    filter1 = all_data['Name'] == stock
    df = all_data[filter1]
    plt.plot(df['date'], df['close'])
    plt.title(stock)


# In[29]:


new_data = all_data.copy()


# In[31]:


ma_window = [10, 20, 50]

for window in ma_window:
    new_data['close_'+ str(window)] = new_data['close'].rolling(window).mean()


# In[32]:


new_data


# In[33]:


new_data.set_index('date', inplace=True)


# In[34]:


new_data.columns


# In[41]:


plt.figure(figsize=(20,12))


for index, stock in enumerate(stocks, 1):
    plt.subplot(2,2, index)
    filter1 = new_data['Name'] == stock
    df = new_data[filter1]
    plt.plot(df[['close_10','close_20', 'close_50']])
    plt.title(stock)


# In[ ]:


plt.figure(figsize=(20,12))


for index, stock in enumerate(stocks, 1):
    plt.subplot(2,2, index)
    filter1 = new_data['Name'] == stock
    df = new_data[filter1]
    df[['close_10', 'close_20', 'close_50']].plot(ax=plt.gca())
    plt.title(stock)


# In[ ]:





# In[42]:


apple = pd.read_csv(r'C:\\Users\\Patel_Shiv\\Downloads\\S&P_resources\\individual_stocks_5yr\\AAPL_data.csv')


# In[48]:


apple['percent_change'] = apple['close'].pct_change()*100


# In[50]:





# In[51]:


apple.head(5)


# In[46]:


import plotly.express as px


# In[52]:


px.line(apple, x='date', y='percent_change')


# In[ ]:





# In[53]:


apple['date'] = pd.to_datetime(apple['date'])


# In[54]:


apple.set_index('date', inplace=True)


# In[56]:


apple['close'].resample('M').mean().plot()


# In[57]:


company_list


# In[61]:


apple = pd.read_csv(company_list[0])
amzn = pd.read_csv(company_list[1])
google = pd.read_csv(company_list[2])
msft = pd.read_csv(company_list[3])


# In[62]:


closing_price = pd.DataFrame()


# In[63]:


closing_price['aapl_close'] = apple['close']
closing_price['amzn_close'] = amzn['close']
closing_price['goog_close'] = google['close']
closing_price['msft_close'] = msft['close']


# In[64]:


closing_price.head(10)


# In[65]:


sns.pairplot(closing_price)


# In[66]:


closing_price.corr()


# In[67]:


sns.heatmap(closing_price.corr(), annot=True)


# In[ ]:





# In[ ]:





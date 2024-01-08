#!/usr/bin/env python
# coding: utf-8

# # Youtube Comments Sentiment Analysis
# 
# In this project I took a Dataset containing youtube commetns from videos posted globally. The data set was organzied so that each country had its own file. 

# First imported libraries and create file path to US Comments data

# In[3]:


import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from textblob import TextBlob

file_path = r"C:\Users\Patel_Shiv\Downloads\Youtube_project\UScomments.csv"


# In[4]:


comments = pd.read_csv(file_path, on_bad_lines='skip')


# In[5]:


comments.head()



# Checking for Null values and cleaning the data

# In[5]:


comments.isnull().sum()


# In[6]:


comments.dropna(inplace=True)


# In[7]:


comments.isnull().sum()


# Creating new column showing polarity of a comment. 

# In[8]:


polarity = [] 

for comment in comments['comment_text']:
    try:
        polarity.append(TextBlob(comment).sentiment.polarity)
    except:
        polarity.append(0)
        


# In[9]:


comments.shape


# In[10]:


comments['polarity'] = polarity


# In[11]:


comments.head(5)


# In[12]:


comments_positive = comments[comments['polarity'] == 1] 


# In[13]:


comments_negative = comments[comments['polarity'] == -1] 


# Creating a world cloud for both positive and negaive commetns based on words in comments gathered from the polarity column just created

# In[14]:


from wordcloud import WordCloud, STOPWORDS 


# In[15]:


total_comments_positive = ' '.join(comments_positive['comment_text'])


# In[16]:


total_comments_negative = ' '.join(comments_negative['comment_text'])


# In[17]:


wordcloud_positive = WordCloud(stopwords = set(STOPWORDS)).generate(total_comments_positive)


# In[18]:


wordcloud_negative = WordCloud(stopwords = set(STOPWORDS)).generate(total_comments_negative)


# Postive Comments Word Cloud

# In[19]:


plt.imshow(wordcloud_positive)
plt.axis('off')


# Negative comments Word Cloud

# In[20]:


plt.imshow(wordcloud_negative)
plt.axis('off')


# Emoji's Analysis

# In[21]:


get_ipython().system('pip install emoji==2.2.0')


# In[22]:


import emoji


# In[23]:


all_emojis_list = [] 

for comment in comments['comment_text'].dropna():
    for char in comment:
        if char in emoji.EMOJI_DATA:
           all_emojis_list.append(char)


# In[24]:


all_emojis_list[0:10]


# In[25]:


from collections import Counter


# In[26]:


Counter(all_emojis_list).most_common(10)


# In[27]:


emojis = [Counter(all_emojis_list).most_common(10)[i][0] for i in range(10)]


# In[28]:


emoji_frequency = [Counter(all_emojis_list).most_common(10)[i][1] for i in range(10)]


# In[29]:


emoji_frequency 


# In[30]:


import plotly.graph_objs as go
from plotly.offline import iplot


# In[31]:


trace = go.Bar(x=emojis, y = emoji_frequency)


# In[32]:


iplot([trace])


# Analyzing the most liked category of videos. 
# 
# First need to get all dat from different files into one place

# In[33]:


import os


# In[34]:


files = os.listdir(r'C:\Users\Patel_Shiv\Downloads\Youtube_project_shan_singh_Udemy\additional_data')


# In[35]:


files_csv = [file for file in files if '.csv' in file]


# In[36]:


files_csv


# In[37]:


import warnings
from warnings import filterwarnings
filterwarnings('ignore')


# In[ ]:





# In[38]:


full_df = pd.DataFrame()
path = r'C:\Users\Patel_Shiv\Downloads\Youtube_project_shan_singh_Udemy\additional_data'

for file in files_csv:
    current_df = pd.read_csv(path + '/' + file, encoding='iso-8859-1', on_bad_lines='skip')
    
    full_df = pd.concat([full_df, current_df], ignore_index=True)


# In[39]:


full_df.shape


# In[40]:


full_df[full_df.duplicated()].shape


# In[41]:


full_df = full_df.drop_duplicates()


# In[42]:


full_df.shape


# Creating DataFrame and adding a column for category of video 

# In[43]:


full_df[0:1000].to_csv(r'C:\Users\Patel_Shiv\Downloads\Youtube_project_shan_singh_Udemy/youtube_sample.csv', index=False)


# In[ ]:





# In[44]:


full_df['category_id'].unique()


# In[45]:


json_df = pd.read_json(r"C:\Users\Patel_Shiv\Downloads\Youtube_project_shan_singh_Udemy\additional_data\US_category_id.json")


# In[47]:


json_df['items'][0]


# In[48]:


cat_dict = {}

for item in json_df['items'].values:
    cat_dict[int(item['id'])] = item['snippet']['title']


# In[49]:


cat_dict


# In[51]:


full_df['category_name'] = full_df['category_id'].map(cat_dict)


# In[52]:


full_df.head(4)


# Box plot showing distribution of most liked categories of videos on YouTube

# In[54]:


plt.figure(figsize=(12,8))
sns.boxplot(x='category_name', y='likes', data=full_df)
plt.xticks(rotation='vertical')


# In[ ]:





# In[55]:


full_df['like_rate'] = (full_df['likes']/full_df['views'])*100
full_df['dislike_rate'] = (full_df['dislikes']/full_df['views'])*100
full_df['comment_rate'] = (full_df['comment_count']/full_df['views'])*100


# In[57]:


full_df.columns


# In[58]:


plt.figure(figsize=(8,6))
sns.boxplot(x='category_name', y='like_rate', data=full_df)
plt.xticks(rotation='vertical')
plt.show()


# In[ ]:





# In[60]:


cdf = full_df['channel_title'].value_counts().reset_index()


# In[66]:


cdf = cdf.rename(columns={'count':'total_videos'})


# In[68]:


import plotly.express as px


# In[69]:


px.bar(data_frame = cdf[0:20], x = 'channel_title', y = 'total_videos' )


# In[ ]:





# In[ ]:





# In[ ]:





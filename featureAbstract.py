# -*- coding: UTF-8 -*-
#install  MYSQL DB for python
import MySQLdb as mdb
import re
import sys
import cPickle
con = None
sql_dict = {}  # dict return from sql
Insensitive_Words = ['for','with','to','','because:','and','will','This','here','on','platform','-','this']
def tuple_wordcount(feature,str):
    # Preprocessing of article string
    # strl_ist = str.replace('\n', '').lower().split(' ')
    strl_ist = str.replace('\n', ' ').lower().split(' ')
    str_after=[];
    for str in strl_ist:
    	if str in Insensitive_Words:
               continue
        str_after.append(str)
   
    count_dict = {}
    # If you have the word in the dictionary, add 1, otherwise add the dictionary.
    for str in str_after:
        if str in count_dict.keys():
            count_dict[str] = count_dict[str] + 1
        else:
            count_dict[str] = 1
    #From high to low in terms of word frequency
    count_list=sorted(count_dict.iteritems(),key=lambda x:x[1],reverse=True)
    sql_dict[feature]=count_list
   # return sql_dict
'''def wordcount2(feature2,str2):
    # 文章字符串前期处理
    # strl_ist = str.replace('\n', '').lower().split(' ')
    strl_ist2 = str2.replace('\n', ' ').lower().split(' ')
    #pre_list2=['for','with','to','','because:','and','will','This','here','on','platform']
    str_after2=[];
    #print strl_ist2
    for str2 in strl_ist2:
        if str2 in Insensitive_Words:
               continue
        str_after2.append(str2)

    count_dict2 = {}
    # 如果字典里有该单词则加1，否则添加入字典
    for str2 in str_after2:
        if str2 in count_dict2.keys():
            count_dict2[str2] = count_dict2[str2] + 1
        else:
            count_dict2[str2] = 1
   # print count_dict2
    #按照词频从高到低排列
    count_list2=sorted(count_dict2.iteritems(),key=lambda x:x[1],reverse=True)
    mat_dict[feature2]=count_list2
   # return sql_dict
'''
def dict_wordcount(dict_order):
    # Preprocessing of article string
    # strl_ist = str.replace('\n', '').lower().split(' ')
    for (k,v) in dict_order.items():
    	str_list = v.replace('\n', ' ').lower().split(' ')
    	str_after=[];
    #print str_list
    	for str in str_list:
        	if str in Insensitive_Words:
               		continue
        	str_after.append(str)

    	count_dict = {}
    # If you have the word in the dictionary, add 1, otherwise add the dictionary.
    	for str in str_after:
        	if str in count_dict.keys():
            		count_dict[str] = count_dict[str] + 1
        	else:
            		count_dict[str] = 1
   # print count_dict
    #From high to low in terms of word frequency
    	count_list=sorted(count_dict.iteritems(),key=lambda x:x[1],reverse=True)
    	dict_order[k]=count_list
    return dict_order

def main():
    try:
 #连接 mysql 的方法： connect('ip','user','password','dbname')
    
    	con = mdb.connect(host='10.244.177.175',user='artsreadonly',passwd='artsreadonly', db='arts');
 #       print sys.argv[1]   
 #所有的查询，都在连接 con 的一个模块 cursor 上面运行的
        cur = con.cursor()
 
 #执行一个查询
        cur.execute("SELECT tblfootprint.footprintId, tblfootprintfield.footprintfield, tblfootprintmap.footprintvalue FROM  tblfootprintfield, tblfootprintmap , tblfootprint WHERE tblfootprint.footprintId=tblfootprintmap.footprintId AND tblfootprintmap.footprintfieldId=tblfootprintfield.footprintfieldId AND tblfootprint.defectnumber='%s'"%sys.argv[1])
 #取得上个查询的结果，是单个结果
        dic_sql = {}
        data = cur.fetchall()
        cut_feature=['platform','Status','Entry-Id','Major-Area','Create-date','Priority','Status-Details','Estimated-Checkin-Date','Type','Last-Status-Change','Product-Area'];   #some feature  we do not care
 
        for r in data:
        	for n in range(1,2,1):
                	if r[1]  in cut_feature :
                		continue
                        tuple_wordcount(r[1],r[2])
        #print sql_dict
        for i in sql_dict.keys():
        	print i,sql_dict[i]      
        f=open('mluinpu.bin')
        data1=cPickle.load(f)
        dic_mat=data1['%s'%sys.argv[1]]
        for key in dic_mat.keys():
        	if key in cut_feature:
                	dic_mat.pop(key)
                elif key in sql_dict.keys():  #dedup 和sql数据一样的
                        dic_mat.pop(key)
        output_dict={}
        output_dict=dict_wordcount(dic_mat)
        for i in output_dict.keys():
                print i,output_dict[i]
    finally:
	if con:
  #无论如何，连接记得关闭
        	con.close()

if __name__ == "__main__":
    main()

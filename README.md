# Youbike-Analysis

```
此分析目的為了解可能造成台北市大安區Youbike缺車的因素，以預測該時段、該站點可能缺車的風險，缺車風險的制定方法為當
rent_value - return_value > quan*0.6時設為1，其他設為0，詳細內容可參考期末報告pdf檔，資料的Excel檔及R統整資料
的程式碼在上方呈現。
但當時我們遇到了資料不平衡的問題，以至於當時使用羅吉斯迴歸預測出的結果全為無缺車風險，因此我利用學習到的機器學習方
法在Python使用SMOTE嘗試解決資料不平衡，試驗各種機器學習方法後，使用羅吉斯迴歸的方法來建模還是最能夠呈現原始資料的
面貌，並且模型的性能不錯，Python程式碼亦在上方呈現。
```
期末報告pdf檔｜[第四組_期末報告_廖珮媗、江馥羽、嚴怡詠、江彤恩](https://github.com/wendy0705/Youbike-Analysis/blob/main/%E7%AC%AC%E5%9B%9B%E7%B5%84_%E6%9C%9F%E6%9C%AB%E5%A0%B1%E5%91%8A_%E5%BB%96%E7%8F%AE%E5%AA%97%E3%80%81%E6%B1%9F%E9%A6%A5%E7%BE%BD%E3%80%81%E5%9A%B4%E6%80%A1%E8%A9%A0%E3%80%81%E6%B1%9F%E5%BD%A4%E6%81%A9.pdf)

資料來源1｜[臺北市公共自行車2.0租借紀錄](https://data.gov.tw/dataset/150635)

資料來源2｜[youbike2.0臺北市公共自行車即時資訊](https://data.gov.tw/dataset/137993)

資料來源3｜[臺北市公共自行車租賃系統站點列表](https://zh.wikipedia.org/wiki/臺北市公共自行車租賃系統站點列表)

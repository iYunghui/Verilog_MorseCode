# Verilog_MorseCode

## 介紹
使用DE0和Verilog開發

### Button

設定DE0 Button 從左到右的功能：
* short：摩斯密碼的短碼
* long：摩斯密碼的長碼
* send：確認送出摩斯密碼
* cycle：循環剛才輸入的摩斯密碼
* reset：輸入錯誤的清空鍵

### Display

* 使用Dot Matrix顯示英文大寫字母和數字
* 使用Seven-Segment Display顯示輸入短碼(S)或長碼(L)

## Module

### segdisplay

按下short或long button後使用2 bits儲存，傳給此module後判斷並在7段顯示器上顯示短碼(S)或長碼(L)

### circle_dis

按下cycle button後，此module會負責在點陣圖上重複循環剛才輸入英文字母和數字

### dot_matrix_dis

負責將5 bits的英文字母或數字顯示在點陣圖上，按下send後會將新的英文字母或數字覆蓋掉舊的。

### clk_div_dot_matrix

### clk_div_circle


### main

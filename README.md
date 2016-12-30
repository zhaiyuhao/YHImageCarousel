# YHImageCarousel
![image](https://github.com/zhaiyuhao/YHImageCarousel/blob/master/demo.gif)
## 三个page的轮播，实现方式：
在轮播的scrollView中添加5个并排的containerView，containerView里放置对应需要展示的图片，每次轮动结束后，删除最前或最后的containerView，同时添加新的containerView（同时将对应的图片添加在containerView中），然后滚动到中间的containerView。
目前版本只支持5张或5张以上图片的轮播，后期支持任何大于零的图片数量的轮播。
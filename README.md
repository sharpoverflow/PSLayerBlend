# PSLayerBlend
Photoshop like UI layer blend in Unity.  
使用unity shader实现的PS中的图层混合效果

Demo使用 Unity 2019.3.15f1 制作，理论上低版本使用也没问题  
Open the demo scene with unity-2019.3.15f1, version before this could be ok

第5部分的shader含有较多的if语句实现色彩空间转换，可能比较耗费效率，酌情使用  
shader which in part 5 includes much if-case，this may cause high gpu usage, making your choice ?!

![image](https://raw.githubusercontent.com/sharpoverflow/PSLayerBlend/main/GitImage/demo.gif)

吐槽下：关于色彩空间，根据维基百科的介绍，PS在图层混合时(第5部分的shader)使用的是HCL色彩空间，但是维基关于这部分的公式有缺失，找了很久的资料。尽管我找到了Adobe官方的说明pdf文档链接，但是下载要钱，放弃。
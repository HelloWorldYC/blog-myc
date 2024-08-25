---
title: Java处理Excel
date: 2024-01-09 21:49:41
tags: [Java,Excel]
---

这几天，因为有一个小需求需要用 Java 处理 Excel，此前我并没有接触过这方面的内容，因此在做的过程中也学了一些，在这里做个总结。   

在 Java 中处理 Excel，可以借助 Apache POI 来进行处理。   
POI 全称是 Poor Obfuscation Implementation，意为简洁版的模糊实现。这个名字听起来会让人摸不着头脑，实际上它是 Apache 提供的对 Microsoft Office 文档读写的包。   

## POI 的基本使用

### 依赖导入

```xml
<dependency>
    <groupId>org.apache.poi</groupId>
    <artifactId>poi</artifactId>
    <version>4.1.2</version>
</dependency>

<dependency>
    <groupId>org.apache.poi</groupId>
    <artifactId>poi-ooxml</artifactId>
    <version>4.1.2</version>
</dependency>
```

### Excel 文档导入

我们知道，Excel 文档也叫做工作簿，工作簿中有一张张工作表。在 POI 中，也是一样的结构，通过 `Workbook` 和 `Sheet` 来对应 Excel 文档和表格。  
在 POI 中，有三种 `Workbook`：
1. `HSSF`：对应 office 2003 格式，即 .xls 格式的文件。
2. `XSSF`：对应 office 2007 及以上版本的格式，即 .xlsx 格式的文件。
3. `SXSSF`：是 `XSSF` 的兼容式流扩展，专门用于处理大型 Excel 文件，以避免内存溢出的问题，适用于需要处理大量数据的场景。

因为项目中没有大型 Excel 文件需要处理，所以用的是 `XSSF` 类型的 `Workbook`，这里也以这种进行示例。   
通过 `Workbook` 在导入 Excel 文档的时候，既可以通过文档路径导入，也可以通过输入流导入。  
```java
// 通过文档路径导入 Excel 文档
String path = "E:\data\test1.xlsx";
Workbook workbook = new XSSFWorkbook(path);

// 通过输入流导入 Excel 文档
String path = "E:\data\test2.xlsx";
FileInputStream fileInputStream = new FileInputStream(path);
Workbook sheets = new XSSFWorkbook(fileInputStream);
```

### 表格操作

```java
// 获取表格：通过表格索引获取，索引从 0 开始
Sheet sheet1 = workbook.getSheetAt(0);

// 获取表格：通过表格名获取
String sheetName = "sheet1";
Sheet sheet2 = workbook.getSheet(sheetName);

// 新建表格
Sheet newSheet = workbook.createSheet("newSheetName");
```

### 行操作

```java
// 获取行，方法参数是行号
Row row = sheet.getRow(1);

// 获取表格的总行数
int rows = sheet.getPhysicalNumberOfRows();

// 新建行，方法参数是行号
Row newRow = sheet.createRow(0);

// 设置行的样式，这个用过没什么效果，最好还是每个单元格单独设置
row.setRowStyle(cellStyle);
```

### 单元格操作

```java
// 获取单元格，方法参数是列号
Cell cell = row.getCell(0);

// 获取单元格的数据类型，共有 6 种类型，在 CellType 枚举类中有定义
CellType cellType = cell.getCellType();

// 获取单元格的值，要根据单元格数据类型来获取，比如 String 类型
String value = cell.getStringCellValue();

// 设置单元格的值，可以设置多种数据类型，比如 String
cell.setCellValue(str);

// 获取总列数
int totalCols = row.getPhysicalNumberOfCells();

// 设置单元格样式
cell.setCellStyle(cellStyle);
```

### 特殊操作

```java
// 格式化单元格中的数据，并返回字符串表示
DataFormatter dataFormatter = new DataFormatter();
String value = dataFormatter.formatCellValue(cell);

// 合并单元格，四个参数分别是合并区域的首行、尾行、首列、尾列
sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, totalCol - 1));

// 设置列宽
sheet.setColumnWidth(colIndex, 20 * 256);
```

### 字体样式设置

```java
// 字体设置
Font font = workbook.createFont();
font.setFontName("微软雅黑");   // 字体类型
font.setBold(true);            // 加粗
font.setFontHeightInPoints((short) 20); // 字体大小

// 样式设置
CellStyle cellStyle = workbook.createCellStyle();
cellStyle.setFont(font);
cellStyle.setAlignment(HorizontalAlignment.CENTER);         // 水平居中
cellStyle.setVerticalAlignment(VerticalAlignment.CENTER);   // 垂直居中
cellStyle.setFillForegroundColor(IndexedColors.LIGHT_GREEN.getIndex()); // 设置单元格背景色
cellStyle.setWrapText(true);    // 文本超出时自动换行，不会挤在一行
DataFormat dataFormat = workbook.createDataFormat();
cellStyle.setDataFormat(dataFormat.getFormat("#0.00")); // 单元格中数据保留两位小数
```

### 导出 Excel 文档
POI 导出 Excel 文档是通过输出流的方式导出的。  
```java
String outputPath ="E:\test\output.xlsx";
FileOutputStream fileOutputStream = new FileOutputStream(outputPath);
workbook.write(fileOutputStream);
```

## 总结

以上就是 POI 的基本使用，当然，还有很多其他的操作，但是暂时还没用到，等用到了再来进行补充。  
总的来说这个其实不难，基本就是对应表格进行处理。使用时最重要的就是要对 Excel 表格中的表结构要有一个清晰的把握，知道各行各列的数据代表着什么，对应着进行处理即可。
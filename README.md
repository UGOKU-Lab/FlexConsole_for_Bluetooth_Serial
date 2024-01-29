[README in English](https://github.com/UGOKU-Lab/FlexConsole_for_Bluetooth_Serial/blob/main/README_EN.md)

# FlexConsole for Bluetooth Serial 
AndroidスマートフォンとBluetoothデバイスを接続し、デバイスのアナログスティック等によるモータの操作やセンサ値の表示などのモニタリングを行うことができます。
Bluetooth ClassicのSPPプロファイルを使用しています。

[デモ映像](https://twitter.com/UGOKU_Lab/status/1736362534809330173)

<img src="https://github.com/UGOKU-Lab/FlexConsole_for_Bluetooth_Serial/assets/27545627/221b82e0-b112-43b0-86f4-3ec827887da3" width="800px">

## 使用方法
### インストール方法
[releaseページ](https://github.com/UGOKU-Lab/FlexConsole_for_Bluetooth_Serial/releases/tag/v0.2.0-alpha)からAndroidで実行可能なapkファイルをダウンロードできます。

### マイコン側プログラム
ESP32で実行可能なArduinoのサンプルコードを公開しています。  
[ESP32_Arduino_for_FlexConsole](https://github.com/UGOKU-Lab/ESP32_Arduino_for_FlexConsole)


## データ交換
このアプリは、3バイトのデータを単位として送受信します。

1番目のバイトデータは`チャンネル`です。
`チャンネル`は、ペイロードの宛先を示します。
システムにより予約されたチャンネルはありません。
任意のチャンネルと要求を紐づけてください。

2番目のバイトデータは、ペイロードである`バリュー`です。
`バリュー`はシングルバイトデータであり、0-255の範囲のデータが格納されます。
小数や符号付の値を使用したい場合、デバイス側でデータを変換してください。

3番目のバイトデータは`チェックサム`です。
この値は、`チャンネル`と`バリュー`の排他的論理和です。

| Index | Data        |                                   |
| :---- | :---------- | :-------------------------------- | 
| 1     | チャンネル   | ペイロードの宛先 (0-255)。         |
| 2     | バリュー     | ペイロード (0-255)。              |
| 3     | チェックサム | チャンネルとバリューの排他的論理和。 |

## ライセンス
Copyright (c) 2023 UGOKU Lab

使用ライブラリ及びそのソースコードのライセンスはアプリ内ライセンスページの記載に準じます。  
その他のソースコード及びアプリ本体はMIT License ([LICENSE](https://github.com/UGOKU-Lab/FlexConsole_for_Bluetooth_Serial/blob/main/LICENSE)) に基づき公開されています。  
MIT Licenseに基づき、本アプリ及びソースコードの使用によって生じた損害等の一切の責任を負いかねます。ご了承ください。

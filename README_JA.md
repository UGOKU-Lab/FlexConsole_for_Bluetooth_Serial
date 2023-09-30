# FlexConsole for Bluetooth Serial 

このアプリは、Bluetooth ClassicのSSPプロファイルを用いてAndroidスマートフォンと
デバイスを接続し、デバイスの制御・監視を可能とします。

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
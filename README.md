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


# FlexConsole for Bluetooth Serial 

An android app that allows you to control and monitor your devices using
Bluetooth with SPP.

## Data Exchange

This app sends/receives 3 bytes as a data unit.

The first byte is `channel` that indicates the destination of the payload.
Since there are no reserved channels, you can define any correspondence between 
channels and requests.

The second byte is `value`: the payload.
`value` is single byte data and it must be in the range 0-255.
If you want to use floating point values or signed values, you need to convert
the values on your device.

The third byte is `checksum`.
The value must equal to XOR of `channel` and `value`.

| Index | Data     |                                         |
| :---- | :------- | :-------------------------------------- | 
| 1     | channel  | The destination of the payload (0-255). |
| 2     | value    | The payload (0-255).                    |
| 3     | checksum | The XOR of the channel and the value.   |

[README in Japanese.](https://github.com/UGOKU-Lab/FlexConsole_for_Bluetooth_Serial/blob/main/README_JA.md)

# FlexConsole for Bluetooth Serial 

An android app that allows you to control and monitor your devices using
Bluetooth with SPP.

## Data Exchange

This app sends/receives 3 bytes as a data unit.

The first byte is `channel` that indicates the destination of the payload.
Since there are no reserved channels, you can define any correspondence between 
channels and requests.

The second byte is `value`: the payload.
`value` is single byte data, so it must be in the range 0-255.
If you want to use floating point values, you need to convert the values on your
device.

The third byte is `checksum`.
The value must equal to XOR of `channel` and `value`.

| Index | Data     |                                         |
| :---- | :------- | :-------------------------------------- | 
| 1     | channel  | The destination of the payload (0-255). |
| 2     | value    | The payload (0-255).                    |
| 3     | checksum | The XOR of the channel and the value.   |

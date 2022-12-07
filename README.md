# tangnano9k-sbc8080-light8080
SBC8080-like computer implemented on Tang Nano 9K using light8080 CPU core

- Tang Nano 9Kで作ったSBC8080風のコンピュータです。
- 8080のコア部分にはlight8080 (https://github.com/jaruiz/light8080 )を使用。周辺部分もそれに含まれるmcuのサンプルコードをベースにしました。
- 電脳伝説(@vintagechips)さんのSBC8080用のプログラムをそのまま(バイナリ互換で)動せるように上記mcuのサンプルコードを改変しました。
- sbc8080_datapackに含まれているHEXファイルがとりあえず動いているようです。

## mcu関連コードの修正内容
- メモリを16KBのROMと32KBのRAMに分割(Tang Nano 9Kではまとめて64KBを確保するにはリソースが足りなかったので。)
- メモリ回りのプログラムの簡略化(サイズの自動調整の削除等)
- 割り込み関係のコード(mcu_irq.vhdl)を除去
- RXDRDYのクリアにバグっぽい部分があったので修正
- mcu_uart.vhdlの簡略化(irq関連の除去)
## 制限事項
- UARTは最低限の通信機能しか実装されていないので、8251のレジスタへのアクセス等は無視されます。


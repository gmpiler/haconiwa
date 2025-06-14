# main関数のテストベンチ
* This is the first benchmark written in C language for HACONIWA CPU
* Souta Gondo, 2025/5/4

## 動作確認済の事項
* lui命令
    * lui sp, 0x1でsp(x2)に0x1000を格納可能
* addi命令
    * 負数を含めて加算が可能
* jal命令
    * label先にジャンプが可能
    * jal命令の+1, +2後の命令はフラッシュし実行の無効化が可能
    * ra(x1)にjal命令+1後命令のアドレスを格納可能
* sw/lw命令
    * 動作可能
* ret命令
    * raに格納しておいた戻り先アドレスを取得しリターンできている
    * jalと同様に，+1, +2個後の命令はフラッシュされる
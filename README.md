
javascrpt で マンデルブロ集合の表示を行うページを作成しました。

http://www.atopon.org/mandel/ のソースコードをベースにしています。

次の変更を加えています。

- javascript のコードは coffeescript で書き換えた。
- css ファイルは sass で書き換えた。
- マウスで画面クリックすると、クリック位置が画面中央に移動するようにした。
- マウスホイールの操作で、ズームイン、ズームアウトするようにした。
- ズーム倍率、画面中央座標をキーボードでキーボードで数値入力できるようにした。
- マウス位置の座標を表示するようにした。

![サンプル画面](http://homepage2.nifty.com/youichi_kato/src/canvas-mandelbrot/public/images/sample-screen.png)

[デモ](http://homepage2.nifty.com/youichi_kato/src/canvas-mandelbrot/public/main.html)　(chrome でアクセスすることを奨励)

[デモ](http://homepage2.nifty.com/youichi_kato/src/canvas-mandelbrot/public2/jsMandelbrot.html)　(chrome でアクセスすることを奨励)

参考サイト
==========

- [Mandelbrot Set in HTML5 v0.06](http://www.atopon.org/mandel/)
- [Mandelbrot Explorer](http://wolframhempel.com/2012/11/20/mandelbrot-set-explorer/)
- [msdn:Mandelbrot Explorer](http://msdn.microsoft.com/ja-jp/library/jj649954%28v=vs.85%29.aspx)
- [HTML5 Mandelbrot set & Julia sets](http://falcosoft.hu/html5_mandelbrot.html)
- [The Mandelbrot Set Using Javascript Worker Threads](http://math.hws.edu/eck/jsdemo/jsMandelbrot.html)
- [動画 Deepest Mandelbrot Set Zoom Animation ever - a New Record! 10^275 (2.1E275 or 2^915) ](http://www.youtube.com/watch?v=0jGaio87u3A&hd=1)

TODO
=====
- web worker を利用すること。
- 色の割り当て方法を複数用意すること。


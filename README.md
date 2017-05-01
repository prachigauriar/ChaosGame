# The Chaos Game

This is a simple Mac app that generates points for the [Chaos Game][ChaosGame]. It was mostly just
a toy app that I built to explore the math, but feel free to use it as an example.

* Implements the very simple mathematics of Chaos Game.
* Uses `NSViewController` with multiple child view controllers to implement a single-window 
  interface.
* Implements a custom view that draws many thousands of mathematical points with decent performance.
  The design of this view isn’t great, but works for now. The implementation uses a backing image to
  avoid having to redraw previously drawn points. It could be improved in the future with a data 
  source protocol that returns the points in a given rect. It also draws concurrently.


## To-Do (at some point)

* Add more vertex selectors.
* Add configurable parameters for point appearance.
* Improve the design of the PointPlotView.


## License

All code is licensed under the MIT license. Do with it as you will.

[ChaosGame]: https://en.wikipedia.org/wiki/Chaos_game

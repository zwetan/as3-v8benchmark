// Copyright 2008 the V8 project authors. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
//       copyright notice, this list of conditions and the following
//       disclaimer in the documentation and/or other materials provided
//       with the distribution.
//     * Neither the name of Google Inc. nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

package libraries.v8
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.text.TextField;
    import flash.text.TextFormat;

    /**
    * A basic benchmark GUI runner.
    * 
    * <p>
    * With a GUI the benchmarks are run asynchronously with ENTER_FRAME events.
    * </p>
    * 
    * @example basic usage
    * <listing version="3.0">
    * <code class="prettyprint">
    * 
    * package test
    * {
    *     import libraries.v8.Benchmark;
    *     import libraries.v8.BenchmarkSuite;
    *     import libraries.v8.BenchmarkGUI;
    * 
    *     public class MyTest extends Sprite
    *     {
    * 
    *         public function MyTest()
    *         {
    *             main();
    *         }
    *         
    *         public function main():void
    *         {
    *         
    *             var ts:BenchmarkSuite = new BenchmarkSuite( "Test", 2000,
    *                                             [ new Benchmark( "test1", test1 ),
    *                                               new Benchmark( "test2", test2 ) ] );
    * 
    *             var gui:BenchmarkGUI = new BenchmarkGUI( 400, 400 );
    * 
    *             addChild( gui );
    *             gui.start();
    *         
    *         }
    * 
    *         public function test1():void
    *         {
    *             //some tests
    *         }
    *
    *         public function test2():void
    *         {
    *             //some tests
    *         }
    * 
    *     }
    * 
    * }
    * 
    * </code>
    * </listing>
    */
    public class BenchmarkGUI extends Sprite
    {
        private var _completed:Number;
        private var _total:Number;
        
        private var _realtime:TextField;
        private var _output:TextField;
        
        private var __w:Number;
        private var __h:Number;
        
        public var autoScroll:Boolean  = true;
        public var outputTrace:Boolean = false;
        
        public function BenchmarkGUI( width:Number = 200, height:Number = 200 )
        {
            super();
            
            __w = width;
            __h = height;
            
            if( stage )
            {
                onAddedToStage();
            }
            else
            {
                addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
            }
        }
        
        private function onAddedToStage( event:Event = null ):void
        {
            removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
            _factory();
        }
        
        private function _factory():void
        {
            _realtime = new TextField();
            _realtime.width  = __w;
            _realtime.height = 20;
            _realtime.background      = true;
            _realtime.backgroundColor = 0xCCCCCC;
            _realtime.defaultTextFormat = new TextFormat( "Arial", 12, 0x000000, true );
            _realtime.text = "";
            
            _output = new TextField();
            _output.multiline = true;
            _output.y      = _realtime.y + _realtime.height;
            _output.width  = __w;
            _output.height = __h - _realtime.height;
            _output.background = true;
            _output.backgroundColor = 0xEEEEEE;
            _output.defaultTextFormat = new TextFormat( "Arial", 12, 0x000000, true );
            _output.text = "";
            
            addChild( _realtime );
            addChild( _output );
        }
        
        public function start():void
        {
            _completed  = 0;
            _total      = BenchmarkSuite.CountBenchmarks();
            
            BenchmarkSuite.RunSuites( { NotifyStep:   showProgress,
                                        NotifyResult: printResult,
                                        NotifyError:  printError,
                                        NotifyScore:  printScore },
                                        this
                                    );
        }
        
        public function write( message:String, realtime:Boolean = false ):void
        {
            if( realtime )
            {
                _realtime.text = message;
            }
            else
            {
                _output.appendText( message + "\n" );
            }
            
            if( autoScroll && (_output.scrollV < _output.maxScrollV) )
            {
                _output.scrollV = _output.maxScrollV;
            }
            
            if( outputTrace )
            {
                trace( message );
            }
        }
        
        public function showProgress( name:String ):void
        {
            var percentage:Number = ((++_completed) / _total) * 100;
            var msg:String = "Running: " + Math.round(percentage) + "% completed.";
            write( msg, true );
        }
        
        public function printResult( name:String, result:* ):void
        {
            write( "name " + name );
            write( "metric v8 " + result );
        }
        
        public function printScore( score:Number ):void
        {
            write( "----" );
            write( "Score: " + score );
        }
        
        public function printError( name:String, err:Error ):void
        {
            write( "[" + name + "]: " + err );
        }
        
    }
}
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
    /**
    * A basic benchmark CLI runner.
    * 
    * <p>
    * Without a GUI the benchmarks are run synchronously with continuation functions.
    * </p>
    * 
    * @example basic usage
    * <listing version="3.0">
    * <code class="prettyprint">
    * 
    * import libraries.v8.Benchmark;
    * import libraries.v8.BenchmarkSuite;
    * import libraries.v8.BenchmarkCLI;
    * 
    * function test1():void
    * {
    *     //some tests
    * }
    *
    * function test2():void
    * {
    *     //some tests
    * }
    *  
    * var ts:BenchmarkSuite = new BenchmarkSuite( "Test", 2000,
    *                                             [ new Benchmark( "test1", test1 ),
    *                                               new Benchmark( "test2", test2 ) ] );
    * 
    * var cli:BenchmarkCLI = new BenchmarkCLI();
    * 
    *     cli.start();
    * 
    * </code>
    * </listing>
    */
    public class BenchmarkCLI
    {
        private var _completed:Number;
        private var _total:Number;
        
        public function BenchmarkCLI()
        {
        }
        
        public function start():void
        {
            _completed  = 0;
            _total      = BenchmarkSuite.CountBenchmarks();
            
            BenchmarkSuite.RunSuites( { NotifyStep:   showProgress,
                                        NotifyResult: printResult,
                                        NotifyError:  printError,
                                        NotifyScore:  printScore }
                                    );
        }
        
        public function showProgress( name:String ):void
        {
            var percentage:Number = ((++_completed) / _total) * 100;
            var msg:String = "Running: " + Math.round(percentage) + "% completed.";
            trace( msg );
        }
        
        public function printResult( name:String, result:* ):void
        {
            trace( 'name ' + name );
            trace( 'metric v8 ' + result );
        }
        
        public function printScore( score:Number ):void
        {
            trace( '----' );
            trace( 'Score: ' + score );
        }
        
        public function printError( name:String, err:Error ):void
        {
            trace( "[" + name + "]: " + err );
        }
        
    }
}
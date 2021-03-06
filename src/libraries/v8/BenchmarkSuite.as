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
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.events.Event;
    

    /**
    * Suites of benchmarks consist of a name and the set of benchmarks in
    * addition to the reference timing that the final score will be based on.
    * 
    * This way, all scores are relative to a reference run
    * and higher scores implies better performance.
    */
    public class BenchmarkSuite
    {
        
        /**
        * Keep track of all declared benchmark suites.
        */
        static public var suites:Array = [];
        
        static public var run:Function;
        static public var stop:Function;
        
        static private var scores:Array;
        
        /**
        * Scores are not comparable across versions. Bump the version if
        * you're making changes that will affect that scores, e.g. if you add
        * a new benchmark or change an existing one. 
        */
        public var version:String = "5";
        
        private var name:String;
        private var reference:Number;
        private var benchmarks:Array;
        private var results:Array;
        private var runner:Object;
        private var loop:Shape;
        
        public function BenchmarkSuite( name:String, reference:Number, benchmarks:Array )
        {
            this.name       = name;
            this.reference  = reference;
            this.benchmarks = benchmarks;
            
            BenchmarkSuite.suites.push( this );
        }
        
        /** 
        * Runs all registered benchmark suites and optionally yields between
        * each individual benchmark to avoid running for too long in the
        * context of browsers. Once done, the final score is reported to the
        * runner.
        */
        public static function RunSuites( runner:Object, ui:DisplayObject = null ):void
        {
            var continuation:Function = null;
            var length:int            = suites.length;
            var index:int             = 0;
            BenchmarkSuite.scores     = [];
            
            function step():void
            {
                while( (continuation != null) || (index < length) )
                {
                    if( continuation != null )
                    {
                        continuation = continuation();
                    }
                    else
                    {
                        var suite:BenchmarkSuite = suites[index++];
                        
                        if (runner.NotifyStart)
                        {
                            runner.NotifyStart( suite.name );
                        }
                        
                        suite.RunStep( runner, ui );
                    }
                }
                
                if (runner.NotifyScore)
                {
                    var score:Number     = BenchmarkSuite.GeometricMean( BenchmarkSuite.scores );
                    var formatted:String = BenchmarkSuite.FormatScore( 100 * score );
                    runner.NotifyScore( formatted );
                }
            }
            
            function async_step( event:Event ):void
            {
                if( index < length)
                {
                    var suite:BenchmarkSuite = suites[index++];
                    
                    if( runner.NotifyStart )
                    {
                        runner.NotifyStart( suite.name );
                    }
                    
                    suite.RunStep( runner, ui );
                }
                else
                {
                    BenchmarkSuite.stop();
                    
                    if( runner.NotifyScore )
                    {
                        var score:Number     = BenchmarkSuite.GeometricMean( BenchmarkSuite.scores );
                        var formatted:String = BenchmarkSuite.FormatScore( 100 * score );
                        runner.NotifyScore( formatted );
                    }
                }
            }
            
            if( ui )
            {
                function run():void
                {
                    ui.addEventListener( Event.ENTER_FRAME, async_step );
                }
                
                function stop():void
                {
                    ui.removeEventListener( Event.ENTER_FRAME, async_step );
                }
                
                BenchmarkSuite.run  = run;
                BenchmarkSuite.stop = stop;
                
                BenchmarkSuite.run();
            }
            else
            {
                step();
            }
        }
        
        /**
        * Computes the geometric mean of a set of numbers.
        */
        public static function GeometricMean( numbers:Array ):Number
        {
            var log:Number = 0;
            for (var i:int = 0; i < numbers.length; i++)
            {
                log += Math.log(numbers[i]);
            }
            return Math.pow(Math.E, log / numbers.length);
        }
        
        /**
        * Converts a score value to a string with at least three significant digits.
        */
        public static function FormatScore(value:Number):String
        {
            if( value > 100 )
            {
                return value.toFixed( 0 );
            }
            else
            {
                return value.toPrecision( 3 );
            }
        }
        
        /** 
        * Counts the total number of registered benchmarks. Useful for
        * showing progress as a percentage.
        */
        public static function CountBenchmarks():Number
        {
            var result:Number = 0;
            for (var i:int = 0; i < suites.length; i++)
            {
                result += suites[i].benchmarks.length;
            }
            return result;
        }
        
        /** 
        * Notifies the runner that we're done running a single benchmark in
        * the benchmark suite. This can be useful to report progress.
        */
        public function NotifyStep( result:* ):void
        {
            this.results.push( result );
            if( this.runner.NotifyStep )
            {
                this.runner.NotifyStep( result.benchmark.name );
            }
        }
        
        /** 
        * Notifies the runner that we're done with running a suite and that
        * we have a result which can be reported to the user if needed.
        */
        public function NotifyResult():void
        {
            var mean:Number = BenchmarkSuite.GeometricMean( this.results );
            var score:Number = this.reference / mean;
            BenchmarkSuite.scores.push( score );
            if( this.runner.NotifyResult )
            {
                var formatted:String = BenchmarkSuite.FormatScore( 100 * score );
                this.runner.NotifyResult( this.name, formatted );
            }
        }
        
        /**
        * Notifies the runner that running a benchmark resulted in an error.
        */
        public function NotifyError( error:Error ):void
        {
            if( this.runner.NotifyError )
            {
                this.runner.NotifyError( this.name, error );
            }
            
            if( this.runner.NotifyStep )
            {
                this.runner.NotifyStep( this.name );
            }
        }
        
        /** 
        * Runs a single benchmark for at least a second and computes the
        * average time it takes to run a single iteration.
        */
        public function RunSingleBenchmark( benchmark:Benchmark ):void
        {
            var elapsed:int = 0;
            var start:int = new Date().valueOf();
            
            for( var n:int = 0; elapsed < 1000; n++ )
            {
                benchmark.run();
                elapsed = new Date().valueOf() - start;
            }
            
            var usec:int = (elapsed * 1000) / n;
            this.NotifyStep( new BenchmarkResult( benchmark, usec ) );
        }
        
        /** 
        * This function starts running a suite, but stops between each
        * individual benchmark in the suite and returns a continuation
        * function which can be invoked to run the next benchmark. Once the
        * last benchmark has been executed, null is returned.
        */
        public function RunStep( runner:Object, ui:DisplayObject = null ):*
        {
            this.results = [];
            this.runner  = runner;
            var length:Number        = this.benchmarks.length;
            var index:Number         = 0;
            var suite:BenchmarkSuite = this;
            
            function async_step( event:Event ):void
            {
                //RunNextSetup
                if( index < length )
                {
                    try
                    {
                        suite.benchmarks[index].Setup();
                    }
                    catch( e:Error )
                    {
                        suite.NotifyError( e );
                        end();
                        return;
                    }
                    
                    //RunNextBenchmark
                    try
                    {
                        suite.RunSingleBenchmark( suite.benchmarks[index] );
                    }
                    catch( e:Error )
                    {
                        suite.NotifyError( e );
                        end();
                        return;
                    }
                    
                    //RunNextTearDown
                    try
                    {
                        suite.benchmarks[index].TearDown();
                    }
                    catch( e:Error )
                    {
                        suite.NotifyError( e );
                        end();
                        return;
                    }
                    
                    index++;
                }
                else
                {
                    suite.NotifyResult();
                    end();
                }
            }
            
            function RunNextSetup():Function
            {
                if (index < length)
                {
                    try
                    {
                        suite.benchmarks[index].Setup();
                    }
                    catch( e:Error )
                    {
                        suite.NotifyError( e );
                        return null;
                    }
                    
                    return RunNextBenchmark();
                }
                
                suite.NotifyResult();
                return null;
            }
            
            function RunNextBenchmark():Function
            {
                try
                {
                    suite.RunSingleBenchmark( suite.benchmarks[index] );
                }
                catch( e:Error )
                {
                    suite.NotifyError( e );
                    return null;
                }
                
                return RunNextTearDown();
            }
    
            function RunNextTearDown():Function
            {
                try
                {
                    suite.benchmarks[index++].TearDown();
                }
                catch( e:Error )
                {
                    suite.NotifyError( e );
                    return null;
                }
                
                return RunNextSetup();
            }
            
            
            if( ui )
            {
                function begin():void
                {
                    BenchmarkSuite.stop();
                    loop.addEventListener( Event.ENTER_FRAME, async_step );
                }
                
                function end():void
                {
                    loop.removeEventListener( Event.ENTER_FRAME, async_step );
                    loop = null;
                    BenchmarkSuite.run();
                }
                
                
                loop = new Shape();
                
                begin();
            }
            else
            {
                return RunNextSetup();
            }
            
        }
        
    }
}
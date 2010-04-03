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

package
{
    import flash.display.Sprite;
    import flash.utils.getTimer;
    
    import libraries.v8.Benchmark;
    import libraries.v8.BenchmarkCLI;
    import libraries.v8.BenchmarkGUI;
    import libraries.v8.BenchmarkSuite;
    
    /**
    * V8 Benchmarks
    * 
    * <p>
    * Simple framework for running the benchmark suites and
    * computing a score based on the timing measurements.
    * </p>
    * 
    * <p>
    * <b>note:</b>
    * see README for details
    * </p>
    */
    [SWF(width="400", height="400", backgroundColor='0xffffff', frameRate='24', pageTitle='v8 benchmark', scriptRecursionLimit='1000', scriptTimeLimit='60')]
    public class v8benchmark extends Sprite
    {
        /**
        * Option to render the test results in a graphic display or not
        */
        public static var display:Boolean = true;
        
        public var gui:BenchmarkGUI;
        public var cli:BenchmarkCLI;
        
        public function v8benchmark()
        {
            main();
            //defaultReferenceNumber();
        }
        
        /**
        * Basic usage of the v8 benchmarks.
        * 
        * exemple of results:
        * 
        *       name Test
        *       metric v8 264
        *       name Test2
        *       metric v8 226
        *       name Test3
        *       metric v8 206
        *       name Test4
        *       metric v8 200
        *       name Test5
        *       metric v8 7014
        *       ----
        *       Score: 444
        * 
        */
        public function main():void
        {
            gui = new BenchmarkGUI();
            cli = new BenchmarkCLI();
            
            var ts:BenchmarkSuite = new BenchmarkSuite( "Test", 2000,
                                                          [ new Benchmark( "test1", test1 ),
                                                            new Benchmark( "test2", test2 ) ] );
            
            var ts2:BenchmarkSuite = new BenchmarkSuite( "Test2", 17000,
                                                          [ new Benchmark( "test3", test3 ),
                                                            new Benchmark( "test4", test4 ) ] );
            
            var ts3:BenchmarkSuite = new BenchmarkSuite( "Test3", 155000,
                                                          [ new Benchmark( "test5", test5 ),
                                                            new Benchmark( "test6", test6 ) ] );
            
            var ts4:BenchmarkSuite = new BenchmarkSuite( "Test4", 1511000,
                                                          [ new Benchmark( "test7", test7 ),
                                                            new Benchmark( "test8", test8 ) ] );
            
            var ts5:BenchmarkSuite = new BenchmarkSuite( "Test5", 1673000,
                                                          [ new Benchmark( "test1", test1 ),
                                                            new Benchmark( "test2", test2 ),
                                                            new Benchmark( "test3", test3 ),
                                                            new Benchmark( "test4", test4 ),
                                                            new Benchmark( "test5", test5 ),
                                                            new Benchmark( "test6", test6 ),
                                                            new Benchmark( "test7", test7 ),
                                                            new Benchmark( "test8", test8 ) ] );
            
            if( display )
            {
                //gui.outputTrace = true;
                addChild( gui );
                gui.start();
            }
            else
            {
                cli.start();
            }
        }
        
        
        /**
        * Generate the default reference number for the different tests
        * 
        * exemple:
        * 
        *       Test: 2000
        *       Test2: 17000
        *       Test3: 155000
        *       Test4: 1511000
        *       Test5: 1673000
        * 
        */
        public function defaultReferenceNumber():void
        {
            var t:Number;
            
            t = getTimer();
            test1();
            test2();
            trace( "Test: " + (getTimer() - t)*1000 );

            t = getTimer();
            test3();
            test4();
            trace( "Test2: " + (getTimer() - t)*1000 );
            
            t = getTimer();
            test5();
            test6();
            trace( "Test3: " + (getTimer() - t)*1000 );
            
            t = getTimer();
            test7();
            test8();
            trace( "Test4: " + (getTimer() - t)*1000 );
            
            t = getTimer();
            test1();
            test2();
            test3();
            test4();
            test5();
            test6();
            test7();
            test8();
            trace( "Test5: " + (getTimer() - t)*1000 );
        }
        
        
        //-------- tests --------
        
        //basic score
        public final function test1():void
        {
            var count:uint = 0;
            
            for( var i:uint = 0; i < 10000; i++ )
            {
                count++;
            }
        }
        
        //better score
//        public final function test1():void
//        {
//            var count:uint = 0;
//            
//            for( var i:uint = 0; i < 100; i++ )
//            {
//                count++;
//            }
//        }
        
        public final function test2():void
        {
            var count:uint = 0;
            
            while( count < 10000 )
            {
                count++;
            }
        }
        
        public final function test3():void
        {
            var count:uint = 0;
            
            for( var i:uint = 0; i < 100000; i++ )
            {
                count++;
            }
        }
        
        public final function test4():void
        {
            var count:uint = 0;
            
            while( count < 100000 )
            {
                count++;
            }
        }
        
        public final function test5():void
        {
            var count:uint = 0;
            
            for( var i:uint = 0; i < 1000000; i++ )
            {
                count++;
            }
        }
        
        public final function test6():void
        {
            var count:uint = 0;
            
            while( count < 1000000 )
            {
                count++;
            }
        }
        
        public final function test7():void
        {
            var count:uint = 0;
            
            for( var i:uint = 0; i < 10000000; i++ )
            {
                count++;
            }
        }
        
        public final function test8():void
        {
            var count:uint = 0;
            
            while( count < 10000000 )
            {
                count++;
            }
        }
        
        
    }
}

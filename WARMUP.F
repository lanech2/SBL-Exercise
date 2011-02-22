\ Csci6221.ba5
\ Stack-based Language Assignment
\ 21 Feb 2011
\ Chris Lane

\ Exercise 1
cr
: greet ." Hey, big spender!" ;
greet cr

: refrain ."  Spend a little time with me." ;
refrain cr

: song cr greet refrain cr ;
song

: greet ." Hey, Fred." ;
cr song
greet cr
\ My theory is that there are two versions of "greet" stored in the dictionary.)
\ "song" is created before the second version of "greet" and that song stores a
\ pointer to the 1st reference to "greet" when "song" is created.
\ The new "greet" is found when executing it from the interpreter because
\ it "shadows" the first "greet.

variable _greeter
: greet1 ." Hey, big spender!" ;
' greet1 _greeter !

: song cr _greeter @ execute refrain cr ;

song \ Prints out: Hey, big spender! Spend a little time with me.

: greet2 ." Stellaaaaaa! " ;
' greet2 _greeter !

song \ What gets printed out?
\ ------------------------------------------------------------------------------
\ Exercise 2
variable _refrain
: refrain1 ."  Spend a little time with variable me." ;
' refrain1 _refrain ! \ Store refrain1 in variable _refrain

: song cr _greeter @ execute _refrain @ execute cr ;

song \ Should be "Stellaaaaaa! Spend a little time with variable me."
\ ------------------------------------------------------------------------------
\ Exercise 3
: load-data cr 0 1 2 3 4 5 6 7 8 9 10 99 ;

: dumper load-data begin dup . 0= until cr ;

dumper

: interleave load-data >r begin dup . r@ . 0= until r> drop cr ;

interleave
\ ------------------------------------------------------------------------------
\ Exercise 4
: array create cells allot
        does> swap cells + ;

\ I found this solution in Programming Forth by Stephen Pelc
: 2array create over , cells * allot
        does> dup @ rot * rot + 1+
                cells + ;

10 5 2array grid cr
7 3 3 grid ! cr
: result ." The value stored at row 4, col 4 is " ;
3 3 grid @ result . cr

\ ------------------------------------------------------------------------------
\ Exercise 5
\ For a simple quadratic equation I store the coefficients in an array, then
\ I process each term in order adding it to the previous result
\ temporarily storing the result on the return stack.

3 array coefficients \ using the previous definition of array
: load-coefficients
        0 coefficients !
        1 coefficients !
        2 coefficients ! ;

: poly-eval load-coefficients ( x a b c   -- x )
        0 coefficients @        ( x         -- x c )
        >r                      ( x c       -- x         ; R: -- c )
        dup                     ( x         -- x x )
        1 coefficients @        ( x x       -- x x b )
        *                       ( x x b     -- x bx )
        r>                      ( x bx      -- x bx c    ; R: c -- )
        +                       ( x bx c    -- x bx+c )
        >r                      ( x bx+c    -- x         ; R: -- bx+c )
        dup                     ( x         -- x x )
        *                       ( x x       -- x^2 )
        2 coefficients @        ( x^2       -- x^2 a )
        *                       ( x^2 a     -- ax^2 )
        r>                      ( ax^2      -- ax^2 bx+c ; R: bx+c -- )
        +                       ( ax^2 xb+c -- ax^2+bx+c )
        .                       ( ax^2+bx+c -- )
;

\ Example: computes 3x^2 -2x + 1 evaluated at x = 5 evaluates to 66
5 3 -2 1 poly-eval

\ handling polynomials of arbitrary degree

0 VALUE poly-degree \ create a value called poly-degree

: degree to poly-degree ; ( n -- ) \ sets the value of poly-degree

poly-degree array coefficients2 \ create an array called coefficients2 the size of poly-degree

: load-coefficients2
        1 poly-degree + 0 DO \ the number of coefficients is 1 greater than the degree
          I coefficients2 ! \ store the coefficient values on the stack into coefficients2
        LOOP
;  ( x cn cn-1 ... c0 -- x )

0 VALUE temp
: set-temp to temp ;

: poly-eval2
        load-coefficients2
        0 coefficients2 @   ( x -- x c0)
        >r                  ( x c0 -- x; R: -- c0 )
        dup                 ( x -- x x )
        1 coefficients2 @   ( x x -- x x c1 )
        *                   ( x x c1 -- x c1x )
        r>                  ( x c1x -- x c1x c0; R: c0 -- )
        +                   ( x c1x c0 -- x c1x+c0 )
        set-temp            ( x c1x+c0 -- x )
        dup                 ( x -- x x )

        1 poly-degree + 2 DO  \ deal with c2 thru cn
          dup
          I 1 ?DO            \ calculate the degree of x
            over            ( x x -- x x x ) ( x x^2 -- x x^2 x )
            *               ( x x -- x x^2 ) ( x x^2 x -- x x^3 )
          LOOP
          I coefficients2 @ ( x x -- x x cI )
          *                 ( x x^2 c2 -- x c2x^2 )
          temp
          +
          set-temp
        LOOP
        temp .
        drop drop \ clear the stack
;

\ Example: computes x^5 + x^4 -2x^3 + x^2 + 4 evaluated at x = 2 evaluates to 40
cr 5 degree 2 1 1 -2 1 0 4 poly-eval2

\ Encapsulate using a defining word.
\ My solutions are a bit fragile and I have found it difficult to put this
\ last part together

: polynomial create
        does> poly-eval2
;


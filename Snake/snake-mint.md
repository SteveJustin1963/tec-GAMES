```
8 w!
2 l!
0 d!
10 s!
[0 0] n!
0 f!
0 g!

:I 
  [0 0] n!
  w 2/ 16 * w 2/ + n 0?!
  0 g!
  N `.i`
;

:M 
  R
  s D
  H
  U
  g /F = (M)
; `.m`

:R
  n /S (
    n /i ? P
  )
  f P `.r`
;

:U
  n 0? h!  `.`
  d 0 = (h 1+ h!) `.`
  d 1 = (h 16+ h!) `.`
  d 2 = (h 1- h!) `.`
  d 3 = (h 16- h!) `.`
  h 0 < (h w w * + h!) `.`
  h w w * >= (h w w * - h!) `.`
  h f = (
    l 1+ l! `.`
    s 1- s! `.`
    h n +! `.`
    N
  ) /E (
    h n +! `.`
    n /S 1- n! `.`
  )
  n /S 1- (
    n /i ? h = (1 g!) `.`
  ) `.u`
;

:N
  /r w % " 16 * w % +
  " f! `.n`
;

:P 
  " 16/ x!
  " 15& y!
  1 y << x w * + c!
  1 c /O `.p`
;

:D
  100 (100()) `.d`
;

:H
  /K
  87 = (d 2 = /F = (3 d!))
  83 = (d 3 = /F = (1 d!))
  65 = (d 0 = /F = (2 d!))
  68 = (d 1 = /F = (0 d!))

`.h`
;


```
```
I M
```

```
// Game field size (8x8 grid)
8 w!

// Initial snake length of 2 segments
2 l!

// Direction (0=right, 1=down, 2=left, 3=up)
0 d!

// Game speed (higher number = slower)
10 s!

// Initialize snake array (stores positions as x*16 + y)
[0 0] n!

// Fruit position
0 f!

// Game over flag (0=playing, 1=game over)
0 g!

// Initialize game state
:I 
  // Reset snake array to initial state
  [0 0] n!
  
  // Place snake head in middle of screen
  w 2/ 16 * w 2/ + n 0?!
  
  // Reset game over flag
  0 g!
  
  // Place first fruit
  N
;

// Main game loop
:M 
  R        // Render current state
  s D      // Add delay based on speed
  H        // Check for input
  U        // Update game state
  g /F = (M)  // Continue if not game over
;

// Render game state
:R
  // Draw all snake segments
  n /S (
    n /i ? P
  )
  // Draw fruit
  f P
;

// Update game state
:U
  // Get current head position
  n 0? h!
  
  // Move head based on direction
  d 0 = (h 1+ h!)     // Right
  d 1 = (h 16+ h!)    // Down
  d 2 = (h 1- h!)     // Left
  d 3 = (h 16- h!)    // Up
  
  // Handle screen wrapping
  h 0 < (h w w * + h!)
  h w w * >= (h w w * - h!)
  
  // Check if snake ate fruit
  h f = (
    l 1+ l!     // Increase length
    s 1- s!     // Increase speed
    h n +!      // Add new head
    N           // New fruit
  ) /E (        // If didn't eat fruit:
    h n +!      // Add new head
    n /S 1- n!  // Remove tail
  )
  
  // Check for collision with self
  n /S 1- (
    n /i ? h = (1 g!)
  )
;

// Generate new fruit at random position
:N
  // Random position within bounds
  /r w % " 16 * w % +
  " f!
;

// Draw pixel at position (converts position to x,y coordinates)
:P 
  // Extract x coordinate (position / 16)
  " 16/ x!
  
  // Extract y coordinate (position & 15)
  " 15& y!
  
  // Calculate screen memory position
  1 y << x w * + c!
  
  // Output to screen
  1 c /O
;

// Delay function (controls game speed)
:D
  // Nested delay loops
  100 (100())
;

// Handle keyboard input
:H
  // Read keyboard
  /K
  
  // Check WASD keys and update direction if valid
  87 = (d 2 = /F = (3 d!))   // W = Up
  83 = (d 3 = /F = (1 d!))   // S = Down
  65 = (d 0 = /F = (2 d!))   // A = Left
  68 = (d 1 = /F = (0 d!))   // D = Right
;

// Start game by typing: I M
```

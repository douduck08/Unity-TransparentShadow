### Supported Features
* Directional light
* Multi-lighting
* Recieve colored shadow by custom shader (forward rendering)
* Recieve colored shadow by custom deferred shader (deferred rendering)
* Inject grayscale shadow into builtin screen-space shadowmap

### TODO Features
* Dynamic bounds of directional light
* Point light
* Spot light

### Issues:
* 因為depth buffer的誤差，導致會把影子畫在透明物件之前的物體上。可能解法：
  * 透過多繪製一張透明物件的深度，在繪製顏色時檢查，只有在物體深度小於這張深度buffer才繪製半透明投影
  * 目前暫時在繪製時用 `dot(data.normalWorld, light.dir)` 去減少瑕疵，但也導致影子的強度不正確
* internal shading在採樣shadow mask時只採用r通道，所以不能完整呈現顏色
* 修改internal shading會導致edit mode下整個場景的顏色有問題 (因為沒有 transparent color map時，Unity預設給的是0.5灰階貼圖)
* 修改builtin screen-space shadowmap在scene view上沒有辦法正常呈現 (因為材質球只有一個)
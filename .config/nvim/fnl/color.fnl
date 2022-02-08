;;; Utilies for converting between color representations

(fn hex->float [hex-color]
  (let [f #(/ (tonumber $1 16) 255)
        (r g b) (string.match hex-color "^%#?(%x%x)(%x%x)(%x%x)$")]
    (string.format "{%f, %f, %f}" (f r) (f g) (f b))))

(fn inplace#hex->float []
 (vim.cmd "normal F#y7l") ; Go to previous '#' character and copy color
 (match (pcall hex->float (vim.fn.getreg "@\""))
  (true color) (do
                 (vim.cmd "normal d7l")
                 (vim.api.nvim_put [color] "c" false false))
  _           nil))

{: inplace#hex->float}

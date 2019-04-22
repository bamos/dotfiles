(setq w3m-command "w3m")

(when (executable-find w3m-command)
  (require 'w3m)
  (w3m-lnum-mode 1)
  (setq w3m-use-toolbar nil)
  (setq w3m-command-arguments '("-M"))
  (setq w2m-use-cookies t)

  (require 'w3m-search)
  (setq w3m-search-default-engine "duckduckgo")
  (add-to-list 'w3m-search-engine-alist
               '("duckduckgo" "http://duckduckgo.com/html/?q=%s" nil))

  (setq w3m-user-agent "Mozilla/5.0 (Linux; U; Android 2.3.3; zh-tw; HTC_Pyramid Build/GRI40) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.")

)

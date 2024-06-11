export EDITOR="code -w"
export PATH=$PATH:/opt/homebrew/opt/djvulibre/bin
export PATH=$PATH:/Users/rajeshkumar/Library/Python/3.11/bin:/usr/bin/python3
export PATH=$PATH:/Users/rajeshkumar/.rbenv/shims/jekyll



alias ghc='gh copilot suggest'
alias qu='/Users/rajeshkumar/XXX/SAVE/CODE/multi-browser.sh'
alias qut='/Users/rajeshkumar/XXX/SAVE/CODE/physics-terms.sh'
alias bkp='open /Users/rajeshkumar/XXX/SAVE/Book/Physics-Stewart.pdf'
alias bkl='open /Users/rajeshkumar/XXX/SAVE/Book/LAlgebra-RonLarson.pdf'
alias dct='open /Users/rajeshkumar/XXX/SAVE/Book/Phy-Dictionary.pdf'
alias o='open .'
alias go='open /Users/rajeshkumar/XXX/GIT/trackerD.html'
alias video_process='/Users/rajeshkumar/XXX/SAVE/CODE/video_process.sh'
alias ocr='/Users/rajeshkumar/XXX/SAVE/CODE/ocr.sh'



alias opd='open https://drive.google.com/drive/folders/1YUoZmdZ_JQn4966IVwzZRjjVS06i7VoL'

alias jn='jupyter notebook'
alias GPT='source /Users/rajeshkumar/XXX/GPT/bin/activate'
alias da='deactivate'

alias ollama-m='ollama run mistral:7b-instruct'
alias ollama-l='ollama run llama2:latest'
alias ollama-g='ollama run gemma:2b'
alias ollama-p='ollama run phi'

alias gadd='cat fadd|xargs git add'
alias gct='git commit -m'
alias gsl='git stash list --date=local'
alias gra='git remote add origin'
alias gpull='git pull --rebase origin main'
alias gpush='git push -u origin main'
alias viz='vi ~/.zshrc'
alias src='source ~/.zshrc'
alias gdiff='find . -type f -name "*.tex" -print0 | xargs -0 git diff --word-diff=color HEAD~1 HEAD | less -R'

alias pl='mkdir -p gar;pdflatex -output-directory=gar'

function cdd(){cd /Users/rajeshkumar/XXX/X}
function cdg(){cd /Users/rajeshkumar/XXX/GIT}
function cdgp(){cd /Users/rajeshkumar/XXX/GITP}

function renameIMG() {
    if [ $# -ne 2 ]; then
        echo "Usage: renameIMG <extension> <start_number>"
        return 1
    fi

    local ext="$1"
    local n="$2"

    find . -maxdepth 1 -type f -name "*.$ext" | while read -r file; do
        mv "$file" "$n.$ext"
        echo "$n.$ext"
        ((n++))
    done
}


function djvu2pdf(){ddjvu -format=tiff "$1.djvu" gar_prefix; convert gar_prefix "$1.pdf";rm gar_prefix;echo "Conversion successfull" }

function ldc(){awk '/\\begin{document}/,/\\end{document}/ {if (!/\\begin{document}/ && !/\\end{document}/) print}' $1
}
function gclone(){git clone --depth=1 "$1"}
function gdif() {
    git diff --word-diff --color=always  HEAD "$1" | less -R
}

function dwnf() {
    local link=$1
    local start=$2
    local end=$3
    for ((i=start; i<=end; i++)); do
        wget --no-check-certificate "$link$i.pdf"
    done
}

function pdfline() {
    local link=$1
    local start=$2
    local end=$3
    local word=$4
    for ((i=start; i<=end; i++)); do
        pdftotext "$link$i.pdf" - | grep "^$word">>pdfline.txt
    done
}




alias gv='git remote add origin https://github.com/rajeshphy/Visible.git'
alias gp='git remote add origin https://github.com/rajeshphy/Private.git'

function rpdf() {
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$1"_reduce.pdf "$1".pdf
}

function rimg() {
    ffmpeg -i "$1"  -vf "scale=iw/2:-1" -q:v "$2"  r_"$1"
}

alias lf-section='cp -r /Users/rajeshkumar/XXX/Nts/lf-section/* .'
alias lf-sectionless='cp -r /Users/rajeshkumar/XXX/Nts/lf-sectionless/* .;echo "Copy IMG Folder"'

function lf(){cat /Users/rajeshkumar/XXX/Nts/lf.tex}
function llf(){cat /Users/rajeshkumar/XXX/Nts/llf.tex}
function nest(){cat /Users/rajeshkumar/XXX/Nts/nested-button.py}

function vin(){open /Users/rajeshkumar/XXX/Nts/"$1".tex}
function vip(){open /Users/rajeshkumar/XXX/Nts/gar/"$1".pdf}

function sc(){open "https://scholar.google.com/scholar?hl=en&as_sdt=0%2C5&q=$1"}

function vipp(){pdflatex -output-directory=/Users/rajeshkumar/XXX/Nts/gar /Users/rajeshkumar/XXX/Nts/"$1".tex;open /Users/rajeshkumar/XXX/Nts/gar/"$1".pdf}
 
function plo(){pdflatex -output-directory=gar "$1".tex;bibtex "gar/$1".aux;pdflatex -output-directory=gar "$1".tex;pdflatex -output-directory=gar "$1".tex;open "gar/$1".pdf}

function op() {open "gar/$1".pdf} 

source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
chruby ruby-3.1.3 # run chruby to see actual version
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/curl/lib"
export CPPFLAGS="-I/opt/homebrew/opt/curl/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/curl/lib/pkgconfig"
export OPENAI_KEY=""

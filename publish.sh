#!/bin/bash
# Публикация / обновление защищённой орг-структуры на GitHub Pages.
# Запуск:  bash ~/Downloads/portraithy-orgstructure/publish.sh
# Делает: пересобирает зашифрованный index.html из актуального локального файла,
# создаёт (или обновляет) репозиторий, пушит, включает GitHub Pages.
set -e
export PATH="/opt/homebrew/bin:$PATH"

SRC="$HOME/Downloads/org-structure/orgstructure.html"
BUILD="$HOME/Downloads/org-structure/build-protected.js"
USERS="$HOME/Downloads/org-structure/users.json"
DIR="$HOME/Downloads/portraithy-orgstructure"
REPO="vnyadvantage-lang/portraithy-orgstructure"

echo "1/5 Пересборка зашифрованной версии (доступы — из users.json)…"
node "$BUILD" "$SRC" "$USERS" > "$DIR/index.html"
printf 'User-agent: *\nDisallow: /\n' > "$DIR/robots.txt"

cd "$DIR"
echo "2/5 Подготовка git…"
git init -q 2>/dev/null || true
git config user.name "vnyadvantage-lang"
git config user.email "v.n.y.advantage@gmail.com"
git add -A
git commit -qm "Орг. структура Portraithy — обновление $(date '+%Y-%m-%d %H:%M')" || echo "  (нет изменений для коммита)"
git branch -M main

echo "3/5 Репозиторий…"
if gh repo view "$REPO" >/dev/null 2>&1; then
  echo "  репозиторий есть — пушим."
  git remote add origin "https://github.com/$REPO.git" 2>/dev/null || true
  git push -u origin main
else
  echo "  создаём репозиторий и пушим."
  gh repo create "$REPO" --public --source=. --remote=origin --push
fi

echo "4/5 Включаем GitHub Pages…"
gh api -X POST "repos/$REPO/pages" -f 'source[branch]=main' -f 'source[path]=/' >/dev/null 2>&1 \
  && echo "  Pages включён." \
  || echo "  Pages уже включён (или включите в Settings → Pages → main / root)."

echo "5/5 Готово!"
echo "Ссылка (заработает через 1-2 минуты): https://vnyadvantage-lang.github.io/portraithy-orgstructure/"
echo "Доступы — из users.json (логин = e-mail, пароль соответствующий)."

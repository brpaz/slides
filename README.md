# slides

Slidev decks, one per subfolder under `decks/`, deployed together to GitHub Pages.

## Add a deck

```
mkdir decks/my-talk
cp decks/example/slides.md decks/my-talk/slides.md
```

## Develop

```
pnpm install
pnpm dev decks/my-talk/slides.md
```

## Build all decks

```
pnpm build:all
```

Outputs each deck to `dist/<deck-name>/` plus a root `dist/index.html` linking them all. Pushing to `main` runs the same build and deploys `dist/` to GitHub Pages.

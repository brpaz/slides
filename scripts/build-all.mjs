import { execFileSync } from 'node:child_process'
import { existsSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import ejs from 'ejs'
import matter from 'gray-matter'

const root = dirname(dirname(fileURLToPath(import.meta.url)))
const decksDir = join(root, 'decks')
const dist = join(root, 'dist')

// GitHub Pages serves this repo under /slides/ (project page, not a user/org root page).
const basePrefix = process.env.BASE_PREFIX ?? '/slides/'

rmSync(dist, { recursive: true, force: true })

const decks = readdirSync(decksDir, { withFileTypes: true })
  .filter(entry => entry.isDirectory())
  .map(entry => entry.name)
  .filter(name => existsSync(join(decksDir, name, 'slides.md')))
  .map(name => {
    const entry = join(decksDir, name, 'slides.md')
    const { data } = matter(readFileSync(entry, 'utf8'))
    const base = `${basePrefix}${name}/`

    console.log(`==> building deck: ${name}`)
    execFileSync('pnpm', ['exec', 'slidev', 'build', entry, '--base', base, '--out', join(dist, name)], {
      stdio: 'inherit',
    })

    return { name, title: data.title ?? name, description: data.description ?? '' }
  })

const template = readFileSync(join(root, 'site', 'index.template.ejs'), 'utf8')
const html = ejs.render(template, { decks })
mkdirSync(dist, { recursive: true })
writeFileSync(join(dist, 'index.html'), html)

console.log(`==> done. output in ${dist}`)

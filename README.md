# mlo.io

Jekyll site for [mlo.io](http://mlo.io)

## Assets

    npm run build
    # Or watch for changes and rebuild
    npm run watch

## Creating a New Post

1. `jekyll draft NAME`
2. Write the post
3. Proof it (`make proof:drafts`)
4. Find a hero image (usually from [Unsplash](https://unsplash.com/))
5. Generate hero images (`script/hero IMAGE NAME`)
6. Add hero name to _tailwind.config.js_
7. Optimize images (`npm run optimize`)
8. Publish the draft (`jekyll publish DRAFT`)
9. Commit & push
10. 💵 Profit 💵

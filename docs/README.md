# User guide

The user guide of ColdIgniter. The pages are Markdown files in `guide/`. [Zensical](https://zensical.org/) builds them into a static site, and a Cloudflare Worker with static assets only serves the site at `https://coldigniter.dev/user_guide/`.

## Files

| File | What it is |
|---|---|
| `guide/` | The pages. |
| `mkdocs.yml` | The settings of the site and the menu. |
| `requirements.txt` | The version of the generator. |
| `wrangler.jsonc` | The settings of the Worker. |

## Build

```sh
cd docs
pip install -r requirements.txt
zensical build --clean
```

The site is written to `dist/user_guide/`. The folder `user_guide/` is there on purpose: the Worker serves a file at the same path as it has in `dist/`.

## Look at it on your own machine

```sh
cd docs
zensical serve
```

To run it as the Worker does:

```sh
cd docs
npx wrangler dev
```

Then open `http://localhost:8787/user_guide/`.

## Deploy

The workflow `.github/workflows/user_guide.yml` builds the guide for every pull request that changes `docs/`. On `trunk` it also deploys, when the repository variable `USER_GUIDE_DEPLOY` is `true` and the secrets `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` are set.

By hand:

```sh
cd docs
npx wrangler deploy
```

## A new page

1. Add a Markdown file in `guide/`.
2. Add it to `nav` in `mkdocs.yml`.

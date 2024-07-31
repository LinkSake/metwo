+++
title = "Goodbye Nextra, hello Hugo"
description = "The story of how do I migrate this site from Nextra into Hugo, also how I'm thinking about blogging now."
date = 2024-07-31T17:00:00-00:00
slug = "goodbye-nextra-hello-hugo"
author = "Luis Angel Ortega"
categories = ["Blogposts"]
tags = ["hugo", "nextra", "blogging"]
draft = false
+++

This blog has been abandoned for years at this point. Since I stopped writing on [Aviyel](HTTPS://aviyel.com), I haven’t done anything very technical, and for more personal writings, I've been advised not to publish them online as freely as I used to, because some submissions consider a story "published" if it’s available on a website.

That doesn't mean I've lost interest in the topic during these years; quite the opposite. Thanks to Hacker News and Mastodon, I’ve discovered a bunch of blogs that I love and that have inspired me for the next stage of my own.

## The Big Static Site Generator Change

Previously, my website used [Nextra](https://github.com/shuding/nextra) and was hosted on [Vercel](https://vercel.com/). Honestly, this combo made development and deployment very easy, as well as adding my custom domain. But since I adopted Nextra in a very early stage, customization was minimal. Now it seems more focused on project documentation pages, and the style can be changed through [Tailwind](https://tailwindcss.com/) helpers.

Even so, during my inactive time, I came across Hugo and started playing around with it. I created several test projects with different themes and goals as practice, and while Hugo has many advantages in terms of speed for generating the website thanks to being built in Go, what caught my attention was the number of pre-made themes and how easy they are to customize. From simple things like colors or other styles via a CSS file to being able to modify essential parts of the theme like headers, the navbar, and the RSS feed. I finally settled on the [hugo-classic](https://github.com/goodroot/hugo-classic) theme with modifications to everything mentioned above.

For hosting, I switched from Vercel to GitHub Pages for the convenience of having everything related to the blog in one place. The domain migration wasn't complex but had its details—nothing that deleting all the records in [Porkbun](https://porkbun.com/) and adding them again couldn’t fix. On the other hand, deployment was more complex. Hugo has a [guide](https://gohugo.io/hosting-and-deployment/hosting-on-github/#prose) in its documentation on how to deploy through an action, but in my opinion, it's incomplete. It misses things like ensuring to include the git submodule if using a theme, among other small tweaks you might need. As of writing this, the site is free of these types of errors, although there are still some style issues on mobile screens.

Overall, despite the multiple attempts it took to get the site up correctly, I’m very happy with the new setup and recommend it to anyone thinking of following this path.

## The New Blog Organization and Philosophy

When I first created the website, I didn’t have much experience reading or following other people’s blogs, so I structured it as best I could. Now things have changed; I know what I like and don’t like, what and how to share.

For now, the layout of the pages will be as follows. Since the main focus of the site is as a blog, the most extensive section will be the writings. Although the RSS feed will group all posts in one place, I didn’t want them to live like that on the site. Blogposts will be for these types of things—simply writings into the void of the internet. Articles are for guides and more technical stuff. Reviews are for writing about movies, books, games, etc. Finally, Works are for my published pieces, though at the moment there’s only one, I hope it will be one of the most extensive.

Outside of the writings, Projects is a showcase of my work, like a small CV of my online footprint. About Me is, well, a short biography, and finally, The Garden is something strange and complex, but basically, it’s where everything else lives. Honestly, it’s the best section.

In the index, I also list what I’m “doing”—what I’m playing, reading, listening to, and watching. It’s just a way to share what I’m passionate about at the moment, with the hope that many of those bullet points will turn into reviews. It also has my latest readings, articles that I find interesting to share and/or comment on.

As for the blog’s philosophy, specifically with the "blogposts," I want to write more. I want to capture the spirit of the blogs I follow with how they share things, without necessarily writing essays or technical guides. I’d also like to write more reviews, share my notes, my favorite quotes. Stop consuming without thinking.

In summary, I want the page to be an excuse to keep writing and sharing.

## The Difference with Social Media

Finally, I’m doing this because I no longer enjoy social media as much as I used to. What was once Twitter has fragmented, Facebook and Instagram have a horrible feed full of ads. Really, where I spend my time now is YouTube and TikTok.

Besides the fact that it’s just not the same anymore, knowing that all my contacts see what I publish in their feed has made me hesitant to post. Here, it’s still public; I can keep sharing the things I’m passionate about without the certainty that everyone will see it. Everyone *can* see it, but no one is forced to.

This post was just to share these thoughts, document the change this page has gone through—a rant and monologue into the air. I don’t have a real conclusion, so I’ll leave it at that.

+++
title = "Thinking Outside the Box an Online Resume With Docz"
description = "With a little bit of creativity and Docz, you can easly have a new online cv in minutes!"
date = 2021-10-21T15:32:45-05:00
slug = "thinking-outside-the-box-an-online-resume-with-docz"
author = "Luis Angel Ortega"
categories = ["Articles"]
tags = ["docz", "javascript", "web development"]
draft = false
+++

One of the best traits of humankind is its curiosity. It is so human that in honor of it we named a Mars rover "Curiosity" in 2003. 

Talking about curiosity in the developer world, open source projects top the list, since by nature they invite us to experiment, modify and share what else we can do with them. This is why I propose to think a little outside the box with [Docz](https://www.docz.site/) - a software documentation tool that is completely open source.

## What is Docz?

Docz is a [Gatsby-based](https://www.gatsbyjs.com/) project that simplifies the process of documenting other projects without worrying about configuration, speed and support.

It provides a library that allows you to write MDX pages instead of HTML or JSX files, handles the routing and provides plugins for all the other needs that you may have. All of this results on projects anyone can contribute to!

Is this simplicity and friendliness that makes Docz a great option for more than just docs.

## Creating our Docz project

Before we can jump into Docz, there are some prerequisites that you will need have in order to create the project:

- [NodeJS](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm#overview)
- [Yarn](https://yarnpkg.com/getting-started/install) or [npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm#overview)

Now that you have the prerequisites, let’s start by creating a new React app with `create-react-app` (CRA)

Go to your terminal and run:

```bash
npx create-react-app my-resume
```

If you don’t have CRA installed, npm will ask you if it’s okay to install `create-react-app` type `y` to continue and let CRA create the new project.

> We are using the command `npx` instead of `npm` since we want to execute a package, not install it to a project. You can read more about it [here](https://stackoverflow.com/questions/50605219/difference-between-npx-and-npm).

Now lets move to the directory of our project and install Docz.

```bash
cd my-resume
yarn add docz # or npm install docz
```

Then let’s remove everything that CRA created for us inside the `src` folder, since we don’t need it.

```bash
rm src/*
```

Also, it is a good idea to add to the .gitignore the .docz folder since we only needed for development.

```.gitignore
# .gitignore

# Docz generated files
.docz/
```

Let’s go and create a file named `index.mdx` and a *hello world* header in the following way.

```mdx
<!-- src/index.mdx -->

---
name: Hello World
route: /
---

# Hello world from Docz!

```

And it’s time to run our development server to see what we have just created.

```bash
yarn docz dev # or npm run docz dev
```

> If you get an error [ERROR #98123](https://github.com/gatsbyjs/gatsby/issues/19922) while trying to run the development server, just delete your `yarn.lock` or `package-json.lock` and the `node_modules` folder and install the dependencies again.

*Et voila!* We have successfully created our Docz project.

![Hello from Docz](/images/post/cv-docz-1.png)

> Now is a good time to commit your files!

## Your time to shine

Before we start adding more pages, let’s create a configuration file named `doczrc.js` on the root of our project. This will help us to set some meta tags easily, but it manages [all the configuration](https://www.docz.site/docs/project-configuration) of our project.

```js
// doczrc.js

export default {
  title: "Luis Angel Ortega",
  description: "Hello, I'm Luis Angel and this is my resume made with Docz!",
  ignore: ["README.md"]
}
```

The title key will set the suffix for our [title tag](https://www.w3schools.com/tags/tag_title.asp) and it will change the text on the top left corner of our project, since it’s an online resume I recommend using your name in this field.

Then, the description key that we added will modify the [meta description tag](https://moz.com/learn/seo/meta-description) on our webpage to display it when it’s looked up or shared online.

The last key will tell Docz to ignore some files and don’t display them on the webpage, as is in this case with the README file.

Now let’s add more pages! I’ll add a contact page with my socials and resume one in the following way

```mdx
<!-- src/contact.mdx -->

---
name: Contact
route: /contact
---

# Contact me! 🗣

---

Let's talk! You can find me on these platforms:

- ✉️ [Email](mailto:hey@luisangelme)
- 🤝 [LinkedIn](https://www.linkedin.com/in/luisangel-ortega)
- 🐙 [GitHub](https://github.com/LinkSake)
- 🐦 [Twitter](https://twitter.com/LinkSake)
- 🌐 [Website](https://luisangel.me)
```

```mdx
<!-- src/resume.mdx -->

---
name: Resume
route: /resume
---

# Resume 💼

---

## Work Experience

<details>
  <summary>Software Developer. <a href='growthconstant.co' target='_blank'>Growth Constant</a>, (Mar. 2021 - Currently)</summary>
  <div style={{marginLeft: '1em'}}>
    <li> Full stack developer (Ruby on Rails) and copywriter for the first project of the start-up: <a href='virtualdash.co' target='_blank'>Virtual Dash </a>.</li>
  </div>
</details>

<details>
  <summary>Backend Developer Intern. <a href='facturasamurai.com' target='_blank'>Factura Samurai</a>, (Aug. - Dec. 2020)</summary>
  <div style={{marginLeft: '1em'}}>
    <li> Implemented the user authentication on the Elixir API. </li>
    <li> Learn and developed serverless services (Cloudflare Workers) with TypeScript. </li>
  </div>
</details>

<details>
  <summary>Full Stack Web Developer. <a href='biobot.farm' target='_blank'>biobot.farm</a>, (Aug. 2019 - Jun. 2020)</summary>
  <div style={{marginLeft: '1em'}}>
    <li> Successfully launched a new service (web application) that was developed form scratch while learning React. </li>
    <li> Documented the web application and taught a colleague to mantener said application. </li>
    <li> Improved speed, functionality and readability of a Python API and micro-services. </li>
  </div>
</details>

## Education

<details>
  <summary>Bachelor's Degree in Information Technologies and Telecomunications. <a href='ulsachihuahua.edu.mx/site' target='_blank'>Universidad La Salle Chihuahua</a>, (Aug. 2016 - Dic. 2020)</summary>
  <div style={{marginLeft: '1em'}}>
    <li> Degree on engineering on information and telecommunication with specialization on mobile development. </li>
    <li> Academic exchange semester at La Salle Ramon Llull University (Barcelona, Spain) from January to June 2019 with the Computer Engineering degree. </li>
  </div>
</details>

## Skills

<details>
  <summary> Languages </summary>
  <div style={{marginLeft: '1em'}}>
    <li>Spanish: Native</li>
    <li>English: Advanced (TOFEL ITP: 627)</li>
  </div>
</details>
<details>
<summary> Tech </summary>
  <div style={{marginLeft: '1em'}}>
    <li> <b> Professional level </b> </li>
    <div div style={{marginLeft: '1em'}}>
      <li>JavaScript (Node, React, Next)</li>
      <li>Ruby (Rails)</li>
      <li>SQL (MySQL, PostgreSQL)</li>
      <li>Version manager (Git)</li>
      <li>HTML & CSS</li>
    </div>
  </div>
  <div style={{marginLeft: '1em'}}>
    <li> <b> Novice Level </b> </li>
    <div style={{marginLeft: '1em'}}>
      <li>Python (Bottle)</li>
      <li>Docker</li>
      <li>UNIX</li>
    </div>
  </div>
</details>

## Achivements

- Essential part of the winning team of the following hackathons:
  - Ideacon (2018)
  - Reset (2018)
- Essential part of the 2nd place team of the Blockchain Mobility Hackathon 2019 in Barcelona, Spain.
```

As you can see, using MDX means that we can use [Markdown syntax](https://www.markdownguide.org/) and [JSX](https://es.reactjs.org/docs/introducing-jsx.html) in the same document, giving a lot of flexibility and customization to our Docz projects.

At the end they will look something like this:

![Contact page](/images/post/cv-docz-2.png)

![Resume page](/images/post/cv-docz-3.png)

## Spice it! Adding a custom component

Now let’s focus on our `index.mdx` file. Let’s change it’s title to "About me"

```mdx
<!-- src/index.mdx -->
---
name: About me
route: /
---

# Hello world from Docz!
```

And then, create a `components` folder inside of the `src` directory. There create a `welcome.jsx` component, this will replace our Markdown heading to make the root page more interesting.

```jsx
// src/components/welcome.jsx

import React from 'react'

const Welcome = ( props ) => {

  const style = {
    container: {
      display: 'flex',
      flexDirection: 'column',
    },
    textContainer: {
      textAlign: 'center'
    },
    imgContainer: {
      paddingTop: '1em'
    },
    img: {
      display: 'flex',
      margin: 'auto',
      maxWidth: '40%',
      borderRadius: '50%',
    },
  }

  return (
    <div style={style.container}>
      <div style={style.textContainer}>
        <h1>{props.title}</h1>
        <span>{props.children}</span>
      </div>
      <div style={style.imgContainer}>
        <img style={style.img} src={props.img} alt={props.title}/>
      </div>
    </div>
  )
}

export default Welcome
```

Here I just made a quick component that takes a title, some text and displays it all centered and the image as a circle, but you can make your creativity go wild on this one!

Next, let’s change index.mdx to import our component and use it to give a warm welcome to all the visitors on our webpage, here is how it looks:

![Welcome page](/images/post/cv-docz-4.png)

## It's alive! Time to deploy

ow that we have our Docz project it’s time to build it and deploy it to GitHub Pages (since we already have the repository there).

First we need to configure some things, go to your doczrc.js file and add a dest key with the value “/docs” and a base key the name of your repo as it’s value.

```js
// doczrc.js

export default {
  title: "Luis Angel Ortega",
  description: "Hello, I'm Luis Angel and this is my resume made with Docz!",
  ignore: ["README.md"],
  dest: "/docs",
  base: "docz-resume"
}
```

The first key is telling Docz to build the project into the docs directory, we’re doing this since GitHub Pages expects the static files to be on the root or docs directories.

The base key is changing the base folder to match the name of the repo in order to make the public files and links to work in GitHub Pages.

Once we have everything correctly configured, we need to build the project with the following command:

```bash
yarn docz build # or npm run docz build
```

When it is done, you will see a docs folder on your project. Commit and push everything to your repo. After that, let’s go to the settings tab on your project and in the left menu go to the Pages section.

![Repo page](/images/post/cv-docz-5.png)

![Settings page](/images/post/cv-docz-6.png)

Then select your main branch (or the branch on which you are working on) and select the docs folder.

![Pages page](/images/post/cv-docz-7.png)

And that is it! In a few minutes your website should be live on the link that GitHub has given you.

![Done!](/images/post/cv-docz-8.png)

![Handsome you](/images/post/cv-docz-9.png)

## The future awaits

In this article we only scratched the surface of what Docz is capable of, so be sure to check their [documentation](https://www.docz.site/docs/getting-started) to learn more.

I encourage you to read about them to make your resume stand out from the crowd and always remember to support the creators of this amazing project and contribute if you can.

Find the repo of the project [here](https://github.com/LinkSake/docz-resume). For end result, check out [GitHub](https://linksake.github.io/docz-resume/).

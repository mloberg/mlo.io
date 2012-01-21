---
layout: blog
---
Last week I heard about [popcorn.js](http://mozillapopcorn.org/), a Mozilla project to bring interactivity to videos on the web. It's a really interesting idea and one I can see actually being used. Being able to pull in Tweets, show a Google Map or a Wikipedia article without having to leave the video, is something that can add a lot to a video. There are [multiple plugins available](http://popcornjs.org/plugins) and you have the ability to write your own (though documentation is a little sparse).

One of the uses I thought of right away was code tutorials. You should display the source code you are talking about and then what that source code does. With the webpage plugin, you can easily show an example, but displaying source code is a little more difficult. With the available plugins, there's not really a good way. So I dived in to what [documentation there is](http://popcornjs.org/creating-plugins) on writing plugins and came up with the Popcorn Source Code Plugin. Make sure this goes after popcorn.js and before your script.

<script src="https://gist.github.com/1364481.js?file=Popcorn.SourceCode.js"></script>

You can also get the [minifed version](https://raw.github.com/gist/1364481/2a98bdcc118fac2cf4fc749b09387a1c5430cb1f/Popcorn.SourceCode.min.js).

If you haven't used Popcorn yet, I recommend checking out [A Look at Popcorn](http://net.tutsplus.com/articles/news/a-look-at-popcorn/) over at Nettuts+.

#### Using the Popcorn SourceCode Plugin

To create a Source Code Popcorn event, simple use the sourceCode

{% highlight javascript %}
var pop = Popcorn("#video");

pop.sourceCode({
	start: 5, // when to start display
	end: 15, // when to stop display
	target: 'source-code', // element's id
	code: "<?php echo 'foo';?>", // the source code
	lang: 'php' // optional
});
{% endhighlight %}

As you can see, it's really simple to create a sourceCode popcorn event.

#### Pretty Code

If you have Google Code Prettify included on the page, it will make a call to prettyPrint() and style your code.

#### That's All

Check out my plugin, give some feedback, suggestions, fork the Gist, and leave a comment below.
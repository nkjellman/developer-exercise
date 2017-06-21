var QuoteApp = {
    Models: {},
    Collections: {},
    Views: {},
    Templates:{}
};
var page=1;
var perPage=10;

QuoteApp.Models.Quote = Backbone.Model.extend({});
QuoteApp.Collections.Quotes = Backbone.Collection.extend({
    model: QuoteApp.Models.Quote,
    url: "https://gist.githubusercontent.com/anonymous/8f61a8733ed7fa41c4ea/raw/1e90fd2741bb6310582e3822f59927eb535f6c73/quotes.json",
    initialize: function(){
        console.log("Quotes initialize");
    }
});

QuoteApp.Templates.quotes = _.template($("#tmplt-Quotes").html());

QuoteApp.Views.Quotes = Backbone.View.extend({
    el: $("#mainContainer"),
    template: QuoteApp.Templates.quotes,

    initialize: function () {
        this.collection.bind("reset", this.render, this);
    },

    render: function () {
        console.log("render");
        console.log(this.collection.length);
        $(this.el).html(this.template());
        this.addAll();
    },

    addAll: function () {
        console.log("addAll");
        this.collection.each(function(item,index) {
            if (index >= perPage*(page-1) && index < perPage*page)
            {
                view = new QuoteApp.Views.Quote({ model: item });
                $("ul", this.el).append(view.render());
            }
        });
    }
});


QuoteApp.Templates.quote = _.template($("#tmplt-Quote").html());
QuoteApp.Views.Quote = Backbone.View.extend({
    tagName: "li",
    template: QuoteApp.Templates.quote,

    render: function () {
        return $(this.el).append(this.template(this.model.toJSON())) ;
    }
});


QuoteApp.Router = Backbone.Router.extend({
    routes: {
        "": "defaultRoute"
    },

    defaultRoute: function () {
        console.log("defaultRoute");
        QuoteApp.quotes = new QuoteApp.Collections.Quotes();
        new QuoteApp.Views.Quotes({ collection: QuoteApp.quotes });
        QuoteApp.quotes.fetch({reset: true});
        console.log(QuoteApp.quotes.length + " quotes");
    }
});

var appRouter = new QuoteApp.Router();
Backbone.history.start();

$("#btnNextPage").click(null, function () {
    page++;
    if (QuoteApp.quotes.length < page*perPage)
        page--;
    QuoteApp.quotes.fetch({reset:true});
    console.log(QuoteApp.quotes.length);
});

$("#btnPrevPage").click(null, function () {
    if (page > 1)
        page--;
    QuoteApp.quotes.fetch({reset:true});
    console.log(QuoteApp.quotes.length);
});

$("#btnLastPage").click(null, function () {
    page = Math.floor(QuoteApp.quotes.length / perPage);
    QuoteApp.quotes.fetch({reset:true});
    console.log(QuoteApp.quotes.length);
});

$("#btnFirstPage").click(null, function () {
    page = 1;
    QuoteApp.quotes.fetch({reset:true});
    console.log(QuoteApp.quotes.length);
});
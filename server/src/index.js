var koa = require("koa");
var app = (module.exports = new koa());
const server = require("http").createServer(app.callback());
const WebSocket = require("ws");
const wss = new WebSocket.Server({ server });
const Router = require("koa-router");
const cors = require("@koa/cors");
const bodyParser = require("koa-bodyparser");

app.use(bodyParser());

app.use(cors());

app.use(middleware);

function middleware(ctx, next) {
  const start = new Date();
  return next().then(() => {
    const ms = new Date() - start;
    console.log(
      `${start.toLocaleTimeString()} ${ctx.response.status} ${
        ctx.request.method
      } ${ctx.request.url} - ${ms}ms`
    );
  });
}

const books = [
  {
    id: 1,
    title: "To Kill a Mockingbird",
    author: "Harper Lee",
    genre: "Fiction",
    quantity: 10,
    reserved: 2,
  },
  {
    id: 2,
    title: "The Great Gatsby",
    author: "F. Scott Fitzgerald",
    genre: "Classic",
    quantity: 15,
    reserved: 5,
  },
  {
    id: 3,
    title: "1984",
    author: "George Orwell",
    genre: "Dystopian",
    quantity: 8,
    reserved: 1,
  },
  {
    id: 4,
    title: "The Catcher in the Rye",
    author: "J.D. Salinger",
    genre: "Coming of Age",
    quantity: 20,
    reserved: 3,
  },
  {
    id: 5,
    title: "Pride and Prejudice",
    author: "Jane Austen",
    genre: "Romance",
    quantity: 12,
    reserved: 0,
  },
  {
    id: 6,
    title: "To the Lighthouse",
    author: "Virginia Woolf",
    genre: "Modernist",
    quantity: 18,
    reserved: 4,
  },
  {
    id: 7,
    title: "One Hundred Years of Solitude",
    author: "Gabriel García Márquez",
    genre: "Magical Realism",
    quantity: 7,
    reserved: 1,
  },
  {
    id: 8,
    title: "The Hobbit",
    author: "J.R.R. Tolkien",
    genre: "Fantasy",
    quantity: 25,
    reserved: 6,
  },
  {
    id: 9,
    title: "The Alchemist",
    author: "Paulo Coelho",
    genre: "Philosophical",
    quantity: 14,
    reserved: 2,
  },
  {
    id: 10,
    title: "The Road",
    author: "Cormac McCarthy",
    genre: "Post-Apocalyptic",
    quantity: 10,
    reserved: 3,
  },
  {
    id: 11,
    title: "Sapiens: A Brief History of Humankind",
    author: "Yuval Noah Harari",
    genre: "Non-Fiction",
    quantity: 5,
    reserved: 1,
  },
  {
    id: 12,
    title: "The Girl on the Train",
    author: "Paula Hawkins",
    genre: "Thriller",
    quantity: 30,
    reserved: 8,
  },
  {
    id: 13,
    title: "The Silent Patient",
    author: "Alex Michaelides",
    genre: "Psychological Thriller",
    quantity: 6,
    reserved: 0,
  },
  {
    id: 14,
    title: "Educated",
    author: "Tara Westover",
    genre: "Memoir",
    quantity: 22,
    reserved: 7,
  },
  {
    id: 15,
    title: "The Night Circus",
    author: "Erin Morgenstern",
    genre: "Fantasy",
    quantity: 9,
    reserved: 2,
  },
];

const router = new Router();

router.get("/books", (ctx) => {
  ctx.response.body = books;
  ctx.response.status = 200;
});

router.get("/reserved", (ctx) => {
  ctx.response.body = books.filter((book) => book.reserved > 0);
  ctx.response.status = 200;
});

router.put("/reserve/:id", (ctx) => {
  // console.log("ctx: " + JSON.stringify(ctx));
  const headers = ctx.params;
  // console.log("body: " + JSON.stringify(headers));
  const id = headers.id;
  if (typeof id !== "undefined") {
    const index = books.findIndex((book) => book.id == id);
    if (index === -1) {
      const msg = "No entity with id: " + id;
      console.log(msg);
      ctx.response.body = { text: msg };
      ctx.response.status = 404;
    } else {
      let book = books[index];
      if (book.reserved < book.quantity) {
        book.reserved++;
        ctx.response.body = book;
        ctx.response.status = 200;
      } else {
        const msg = "No more copies available!";
        console.log(msg);
        ctx.response.body = { text: msg };
        ctx.response.status = 404;
      }
    }
  } else {
    ctx.response.body = { text: "Id missing or invalid" };
    ctx.response.status = 404;
  }
});

router.put("/borrow/:id", (ctx) => {
  const headers = ctx.params;
  const id = headers.id;
  if (typeof id !== "undefined") {
    const index = books.findIndex((book) => book.id == id);
    if (index === -1) {
      const msg = "No entity with id: " + id;
      console.log(msg);
      ctx.response.body = { text: msg };
      ctx.response.status = 404;
    } else {
      let book = books[index];
      if (book.reserved > 0) {
        book.reserved--;
        ctx.response.body = book;
        ctx.response.status = 200;
      } else {
        const msg = "No more copies available!";
        console.log(msg);
        ctx.response.body = { text: msg };
        ctx.response.status = 404;
      }
    }
  } else {
    ctx.response.body = { text: "Id missing or invalid" };
    ctx.response.status = 404;
  }
});

const broadcast = (data) =>
  wss.clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify(data));
    }
  });

router.post("/book", (ctx) => {
  // console.log("ctx: " + JSON.stringify(ctx));
  const headers = ctx.request.body;
  // console.log("body: " + JSON.stringify(headers));
  const title = headers.title;
  const author = headers.author;
  const genre = headers.genre;
  const quantity = headers.quantity;
  const reserved = headers.reserved;
  if (
    typeof title !== "undefined" &&
    typeof author !== "undefined" &&
    typeof genre !== "undefined" &&
    typeof quantity !== "undefined" &&
    typeof reserved !== "undefined"
  ) {
    const index = books.findIndex(
      (book) => book.title == title && book.author == author
    );
    if (index !== -1) {
      const msg = "The entity already exists!";
      console.log(msg);
      ctx.response.body = { text: msg };
      ctx.response.status = 404;
    } else {
      let maxId =
        Math.max.apply(
          Math,
          books.map((book) => book.id)
        ) + 1;
      let book = {
        id: maxId,
        title,
        author,
        genre,
        quantity,
        reserved,
      };
      books.push(book);
      broadcast(book);
      ctx.response.body = book;
      ctx.response.status = 200;
    }
  } else {
    const msg =
      "Missing or invalid title: " +
      title +
      " author: " +
      author +
      " genre: " +
      genre +
      " quantity: " +
      quantity +
      " reserved: " +
      reserved;
    console.log(msg);
    ctx.response.body = { text: msg };
    ctx.response.status = 404;
  }
});

app.use(router.routes());
app.use(router.allowedMethods());

// const port = 2429;
const port = 2325;

server.listen(port, () => {
  console.log(`🚀 Server listening on ${port} ... 🚀`);
});

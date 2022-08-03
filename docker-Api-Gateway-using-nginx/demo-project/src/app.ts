import { ExpressApplication, IOptions } from "@rafat97/express-made-easy";
import fetch from "node-fetch";

const config: IOptions = {
  appName: process.env.APP_SERVICE_NAME,
  appHost: "0.0.0.0",
  appPort: parseInt(process.env.APP_PORT || "8000") || 8000,
};

console.log(process.env);

const expressApp = new ExpressApplication(config)
  .addDefaultMiddleware()
  .getMethod("/", (req: any, res: any) => {
    const url = "http://" + req.headers.host;
    return res.json({
      routes: [
        {
          path: url + "/",
          describe: "Root url",
          method: "GET",
        },
        {
          path: url + "/error",
          describe: "Without Async Error",
          method: "GET",
        },
        {
          path: url + "/error-async",
          describe: "With Async Error",
          method: "GET",
        },
        {
          path: url + "/healthz",
          describe: "health status",
          method: "GET",
        },
        {
          path: url + "/fetch-data",
          describe: "With Async Error",
          method: "GET",
        },
        {
          path: url + "/any-random-data",
          describe: "Any Random Url",
          method: "GET",
        },
      ],
      env: process.env,
    });
  })
  .getMethod("/fetch-data", async (req: any, res: any) => {
    const url = "https://jsonplaceholder.typicode.com/todos";
    console.log(url);

    const response = await fetch(url);
    const body = await response.json();
    console.log(body);
    return res.send({
      body,
    });
  })
  .getMethod("/error", (req: any, res: any) => {
    throw new Error("Without Async Error");
    return res.send({
      message: "Hello World test service",
    });
  })
  .getMethod("/error-async", async (req: any, res: any) => {
    throw new Error("With Async Error");
    return res.send({
      message: "Hello World test service",
    });
  })
  .allMethod("/healthz", async (req: any, res: any) => {
    return res.status(200).send({
      message: "UP",
    });
  })
  .allMethod("*", async (req: any, res: any) => {
    return res.status(404).send({
      message: "Error allMethod",
    });
  })
  .addErrorHandler((err: any, req: any, res: any, next: any) => {
    return res.status(400).send({
      message: err.message,
    });
  })
  .startServerSync();

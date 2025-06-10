# Local network, routing (mild hosting)

If you have multiple laptops on the same wifi router, you can access one machine from another by using their private IP address. This is a mild version of deploying your app on your local network (or whats called the intranet)

## Steps to follow

1. Start a node.js process locally on port 3000

```javascript
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello, World!');
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
```
2) Find the IP of your machine on the local network

```
ifconfig or ipconfig
```

Hosts file
You can override what your domain name resolves to by overriding the hosts file.

```
vi /etc/hosts
127.0.0.01	harkirat.100xdevs.com
```

You can try one more command , to check your ip
```
npx serve
```

Reference : 
1) https://petal-estimate-4e9.notion.site/Local-network-routing-mild-hosting-1867dfd1073580b08adad715797481bc

FROM node:24-alpine

RUN npm install -g @ethersphere/swarm-cli

ENTRYPOINT ["swarm-cli"]
CMD ["--help"]

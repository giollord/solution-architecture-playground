# AGENTS.md

This file provides guidance to AI coding agents working with code in this repository.

## Purpose

Playground for learning solution and software architecture without going into implementation details. Treat feature code (like the weather forecast demo) as disposable scaffolding — the point of this repo is exploring architecture/orchestration patterns (.NET Aspire, service composition), not building out a real product.

## Architecture

This is a .NET Aspire distributed application with three projects wired together via `Playground.AppHost`:

- **Playground.AppHost** — the Aspire orchestrator (`AppHost.cs`). It declares the distributed app graph: starts `Playground.Server`, starts `playground-frontend` as a Vite app (via `Aspire.Hosting.JavaScript`), and wires the frontend to the server with `WithReference`/`WaitFor`. `server.PublishWithContainerFiles(webfrontend, "wwwroot")` means the built frontend is published into the server's `wwwroot` for container/publish scenarios — the server serves the frontend statically (`app.UseFileServer()` in `Program.cs`) rather than these being deployed as fully separate services.
- **Playground.Server** — ASP.NET Core minimal API (net10.0). `Program.cs` wires up service defaults, OpenAPI, exception handling, and API endpoints under `/api` (currently just `/api/weatherforecast`). `Extensions.cs` holds the standard Aspire "ServiceDefaults" pattern inlined into this project (OpenTelemetry, health checks at `/health` and `/alive`, service discovery, HTTP resilience) — normally this lives in a separate `ServiceDefaults` project, but here it's folded directly into `Playground.Server`.
- **playground-frontend** — React 19 + TypeScript + Vite SPA. Calls the backend via relative `/api/...` paths (proxied/composed by Aspire during `dev`, served from `wwwroot` in published builds). No router or state library yet — single `App.tsx`.

When adding new backend endpoints, group them under the existing `api` route group in `Program.cs`. When adding new Aspire-managed resources (databases, caches, other services), add them in `AppHost.cs` and reference them from the consuming project via `WithReference`.

## Commands

### Run the full distributed app (recommended entry point)
```
dotnet run --project Playground.AppHost
```
This starts the Aspire dashboard, the server, and the Vite dev server together.

### Backend only
```
dotnet build Playground.sln
dotnet run --project Playground.Server
```

### Frontend only
```
cd playground-frontend
npm install
npm run dev       # Vite dev server
npm run build     # tsc -b && vite build
npm run lint      # eslint .
npm run preview
```

There are no test projects/scripts in the repo yet.

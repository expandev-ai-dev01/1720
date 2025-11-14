# LoveCakes Backend

Backend API for LoveCakes - Cake ordering and sales platform

## Project Structure

```
src/
├── api/                    # API Controllers
│   └── v1/                 # API Version 1
│       ├── external/       # Public endpoints
│       └── internal/       # Authenticated endpoints
├── routes/                 # Route definitions
│   └── v1/                 # Version 1 routes
├── middleware/             # Express middleware
├── services/               # Business logic services
├── utils/                  # Utility functions
├── constants/              # Application constants
├── instances/              # Service instances
├── config/                 # Configuration
└── server.ts               # Application entry point
```

## Getting Started

### Prerequisites

- Node.js 18+
- TypeScript 5+
- SQL Server database

### Installation

```bash
npm install
```

### Environment Configuration

Copy `.env.example` to `.env` and configure your environment variables:

```bash
cp .env.example .env
```

### Development

```bash
npm run dev
```

### Build

```bash
npm run build
```

### Production

```bash
npm start
```

### Testing

```bash
npm test
```

## API Endpoints

### Health Check

```
GET /health
```

### API Version 1

```
/api/v1/external/*  - Public endpoints
/api/v1/internal/*  - Authenticated endpoints
```

## Database

The application uses SQL Server with stored procedures for data operations.

### Connection Configuration

Database connection is configured in `src/config/index.ts` using environment variables.

## Development Guidelines

- Follow TypeScript strict mode
- Use path aliases (@/) for imports
- Implement proper error handling
- Write tests for all business logic
- Document all API endpoints
- Follow RESTful conventions

## License

ISC
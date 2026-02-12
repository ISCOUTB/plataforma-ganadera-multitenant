import { NestFactory } from '@nestjs/core';
import { ValidationPipe, VersioningType, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create(AppModule);

  const configService = app.get(ConfigService);

  // Enable CORS
  app.enableCors({
    origin: true,
    credentials: true,
  });

  // Global prefix
  const apiVersion = configService.get<string>('app.apiVersion');
  app.setGlobalPrefix(`api/${apiVersion}`);

  // API Versioning
  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: '1',
  });

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Swagger configuration
  const swaggerEnabled = configService.get<boolean>('swagger.enabled');

  if (swaggerEnabled) {
    const config = new DocumentBuilder()
      .setTitle('FarmLink API')
      .setDescription('FarmLink Backend API Documentation')
      .setVersion('1.0')
      .addBearerAuth(
        {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          name: 'JWT',
          description: 'Enter JWT token',
          in: 'header',
        },
        'JWT-auth',
      )
      .addServer(`http://localhost:${configService.get<number>('app.port')}`, 'Local server')
      .addTag('Authentication', 'Authentication endpoints')
      .addTag('Users', 'User management endpoints')
      .addTag('Tenants', 'Tenant management endpoints')
      .build();

    const document = SwaggerModule.createDocument(app, config);
    
    // Swagger sin prefijo adicional, directamente en /api/docs
    SwaggerModule.setup('api/docs', app, document, {
      swaggerOptions: {
        persistAuthorization: true,
        tagsSorter: 'alpha',
        operationsSorter: 'alpha',
      },
    });

    logger.log(`Swagger documentation available at /api/docs`);
  }

  const port = configService.get<number>('app.port');
  await app.listen(port);

  logger.log(`Application is running on: http://localhost:${port}/api/${apiVersion}`);
  if (swaggerEnabled) {
    logger.log(`Swagger UI available at: http://localhost:${port}/api/docs`);
  }
}

bootstrap();

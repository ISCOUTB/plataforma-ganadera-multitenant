import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from 'helmet';
import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  // Seguridad
  app.use(helmet());
  app.enableCors({
    origin: true,
    credentials: true,
  });

  // Validación global
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

  // Filtros globales
  app.useGlobalFilters(new AllExceptionsFilter(), new HttpExceptionFilter());

  // Interceptores globales
  app.useGlobalInterceptors(new TransformInterceptor());

  // Prefix global
  const apiPrefix = configService.get<string>('apiPrefix');
  app.setGlobalPrefix(apiPrefix);

  // Swagger
  const config = new DocumentBuilder()
    .setTitle('Plataforma Ganadera API')
    .setDescription('Sistema multitenant para gestión ganadera')
    .setVersion('1.0')
    .addBearerAuth()
    .addTag('Tenants', 'Gestión de tenants')
    .addTag('Users', 'Gestión de usuarios')
    .addTag('Auth', 'Autenticación y autorización')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('docs', app, document);

  const port = configService.get<number>('port');
  await app.listen(port);

  console.log(`🚀 Application running on: http://localhost:${port}/${apiPrefix}`);
  console.log(`📚 Swagger docs: http://localhost:${port}/docs`);
  console.log(`🗄️  Database: ${configService.get('database.name')}`);
}
bootstrap();
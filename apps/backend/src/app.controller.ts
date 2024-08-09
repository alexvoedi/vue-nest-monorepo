import { Controller, Get, Logger } from '@nestjs/common'
import { text } from 'common'

@Controller()
export class AppController {
  private readonly logger = new Logger(AppController.name)

  constructor() {}

  @Get()
  getHello() {
    return {
      message: text,
      date: new Date(),
    }
  }

  @Get('health')
  health() {
    this.logger.log('Health check')

    return {
      status: 'ok',
    }
  }
}

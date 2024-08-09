import { Controller, Get } from '@nestjs/common'
import { text } from 'common'

@Controller()
export class AppController {
  constructor() {}

  @Get()
  getHello() {
    return {
      message: text,
      date: new Date(),
    }
  }
}

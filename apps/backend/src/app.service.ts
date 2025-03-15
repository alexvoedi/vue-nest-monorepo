import { Injectable } from '@nestjs/common'
import { helloWorld } from 'common'

@Injectable()
export class AppService {
  getHello(): string {
    return helloWorld
  }
}

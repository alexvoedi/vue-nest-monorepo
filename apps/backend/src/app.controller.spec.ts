import { Test, TestingModule } from '@nestjs/testing'
import { AppController } from './app.controller'

describe('appController', () => {
  let appController: AppController

  beforeEach(async () => {
    const app: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [],
    }).compile()

    appController = app.get<AppController>(AppController)
  })

  describe('root', () => {
    it('should return "Hello World!"', () => {
      expect(appController.getHello()).toMatchObject({ message: 'Hello World' })
    })
  })
})

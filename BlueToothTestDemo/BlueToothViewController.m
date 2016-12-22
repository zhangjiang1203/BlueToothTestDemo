//
//  BlueToothViewController.m
//  BlueToothTestDemo
//
//  Created by pg on 2016/12/21.
//  Copyright © 2016年 DZHFCompany. All rights reserved.
//

#import "BlueToothViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
@interface BlueToothViewController ()<CBCentralManagerDelegate,UITableViewDataSource,UITableViewDelegate,CBPeripheralDelegate>
{
    NSMutableArray <CBPeripheral*>*peripheralArr;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (nonatomic,strong) CBCentralManager *cMgr;//中心管理设备
@end

@implementation BlueToothViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    peripheralArr = [NSMutableArray array];
    [self cMgr];
        
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return peripheralArr.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"systemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"当前的设备:%@",peripheralArr[indexPath.row].name];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.cMgr connectPeripheral:peripheralArr[indexPath.row] options:nil];
}

//懒加载中心管理者
-(CBCentralManager*)cMgr{
    if (!_cMgr) {
        _cMgr = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    return _cMgr;
}

#pragma mark -CBCenteralManagerDelegate
//中心管理者状态，初始化的时候会打开设备，设备打开之后才能使用
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@"状态未知");
            break;
        case CBManagerStateResetting:
            NSLog(@"重置设备");
            break;
        case CBManagerStateUnsupported:
            NSLog(@"当前设备不支持");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@"当前设备没有授权");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@"当前设备已关闭");
            break;
        case CBManagerStatePoweredOn:
            NSLog(@"当前设备打开");
            //开始扫描周围外设
            [self.cMgr scanForPeripheralsWithServices:nil options:nil];
            break;
        default:
            break;
    }
}
//扫描设备会进入到此的代理方法
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"%s,line = %d,per = %@,data = %@,rssi = %@",__FUNCTION__,__LINE__,peripheral,advertisementData,RSSI);
    if (peripheral.name) {
        if (![peripheralArr containsObject:peripheral]) {
            [peripheralArr addObject:peripheral];
        }
    }
    [self.myTableView reloadData];
}

//链接外设成功
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"%s,line = %d",__FUNCTION__,__LINE__);
    NSLog(@"连接到名称为(%@)的设备-成功",peripheral.name);
    //设置peripheral代理
    [peripheral setDelegate:self];
    //扫描外设Services成功后
    [peripheral discoverServices:nil];
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"%s,line = %d",__FUNCTION__,__LINE__);
    NSLog(@"连接到名称为(%@)的设备-失败",peripheral.name);
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"%s,line = %d",__FUNCTION__,__LINE__);
    NSLog(@"丢失连接到名称为(%@)的设备-失败",peripheral.name);
}

//链接成功之后进入的代理方法
//发现外设的service
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        NSLog(@"discovered services for %@ with error: %@",peripheral.name,error.localizedDescription);
        return;
    }
    
    for (CBService *service in peripheral.services) {
        NSLog(@"service.UUID = %@",service.UUID);
        //扫描每个Service的characteristics,扫描到调用方法 peripheral:didDiscoverCharateristicsForservice:error
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

//获取characteristic的值
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"获取(%@)设备的characteristic值出错:%@",service.UUID,error.localizedDescription);
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"服务的Service.UUID=%@,characteristic.UUID=%@",service.UUID,characteristic.UUID);
        //获取characteristic的值,读到数据会调用方法 peripheral:didUpdateValueForCharacterstic:error
        [peripheral readValueForCharacteristic:characteristic];
        //搜索characteristic的description，调用peripheral:didDiscoverDescriptorsForCharacteristic:error
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
}

//获取characteristic的值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //打印出characteristic的UUID和值
    //value的类型是NSData 具体开发时，会根据外设协议制定的方式去解析数据
    NSLog(@"%s, line = %d, characteristic.UUID:%@  value:%@", __FUNCTION__, __LINE__, characteristic.UUID, characteristic.value);
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    //打印出DescriptorsUUID 和value
    //这个descriptor都是对于characteristic的描述，一般都是字符串，所以这里我们转换成字符串去解析
    NSLog(@"%s, line = %d, descriptor.UUID:%@ value:%@", __FUNCTION__, __LINE__, descriptor.UUID, descriptor.value);

}

// 发现特征Characteristics的描述Descriptor
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    for (CBDescriptor *descriptor in characteristic.descriptors) {
        NSLog(@"descriptor.UUID:%@",descriptor.UUID);
    }
}
@end

//
//  Logs.swift
//  KubeCmd
//
//  Created by Thomas Horrobin on 03/09/2021.
//

import SwiftUI
import SwiftkubeClient

struct LogsHandler: View {
	var resources: ClusterResources
	@State var logs: String
	init(podName name: String, resources resourcesPointer: ClusterResources) throws {
		resources = resourcesPointer
		podName = name
		logs = "no logs yet received by KubeCmd"
	}
	var podName: String
	func refreashLogs() async -> Void {
		do {
			logs = try await resources.getLogs(name: podName, all: false)
		} catch  {
			print("error")
		}
	}
	func downloadLogs() async -> Void {
		let paths = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
		let firstPath = paths[0]
		let filename = firstPath.appendingPathComponent("\(podName).log")
		print(filename.absoluteString)
		do {
			let downloadedLogs = try await resources.getLogs(name: podName, all: true)
			try downloadedLogs.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
		} catch {
			print(error)
			// failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
		}
	}
	var body: some View {
		LogsView(logs: logs, refreashLogs: refreashLogs, downloadLogs: downloadLogs).padding(40).frame(width: 800, height: 500, alignment: .center).task {
			await refreashLogs()
		}
	}
}

struct LogsView: View {
	var logs:String
	var refreashLogs:() async -> Void
	var downloadLogs:() async -> Void
	var body: some View {
		VStack(alignment: .leading){
			HStack{
				Text("Logs").font(.title2).frame(alignment: .center)
				Spacer()
				Button(action: {
					Task{
						await refreashLogs()
					}
				}) {
					Image(systemName: "arrow.clockwise")
				}
			}
			ScrollView{
				Text(logs).frame(
					   minWidth: 0,
					   maxWidth: .infinity,
					   minHeight: 350,
					   maxHeight: .infinity,
					   alignment: .leading
				   ).foregroundColor(Color.green).background(Color.black)
			}
			HStack(alignment: .top) {
				Button {
					Task {
						await downloadLogs()
					}
				} label: {
					Image(systemName: "icloud.and.arrow.down")
					Text("Save to Downloads")
				}
				
			}
		}
	}
}

struct Logs_Previews: PreviewProvider {
	static var dummyData = [String](
		arrayLiteral:
			"2021/09/07 15:43:13 5053/300000 https://directlyapply.com/jobs/randstad-us/61378890a8cf4c3be7b99fc4 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:14 5054/300000 https://directlyapply.com/jobs/aston-carter/61378891a8cf4c3be7b99fc6 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:14 Error 1062: Duplicate entry 'Software Engineer' for key 'SimularJobTitles.PRIMARY'",
		"2021/09/07 15:43:15 5055/300000 https://directlyapply.com/jobs/new-relic/61378892a8cf4c3be7b99fc8 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:16 5057/300000 https://directlyapply.com/jobs/ey/61378893a8cf4c3be7b99fcb CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:17 5058/300000 https://directlyapply.com/jobs/hill-bros/61378894a8cf4c3be7b99fcc CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:17 Error 1062: Duplicate entry 'Software Engineer' for key 'SimularJobTitles.PRIMARY'",
		"2021/09/07 15:43:18 5061/300000 https://directlyapply.com/jobs/constellation-technologies/61378896a8cf4c3be7b99fd0 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:19 5062/300000 https://directlyapply.com/jobs/ac-hotels/61378896a8cf4c3be7b99fd2 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:20 5063/300000 https://directlyapply.com/jobs/pacific-architects-and-engineers/61378897a8cf4c3be7b99fd3 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:20 5064/300000 https://directlyapply.com/jobs/job-juncture/61378898a8cf4c3be7b99fd5 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:22 5066/300000 https://directlyapply.com/jobs/crystal-run-healthcare/61378899a8cf4c3be7b99fd9 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:24 5069/300000 https://directlyapply.com/jobs/deloitte/6137889ca8cf4c3be7b99fdd CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:26 5071/300000 https://directlyapply.com/jobs/farmers-bank-and-trust/6137889da8cf4c3be7b99fe0 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:26 5072/300000 https://directlyapply.com/jobs/blockone/6137889ea8cf4c3be7b99fe1 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:27 5073/300000 https://directlyapply.com/jobs/center-for-health-information-and-analysis/6137889fa8cf4c3be7b99fe4 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:28 5074/300000 https://directlyapply.com/jobs/iboss/6137889fa8cf4c3be7b99fe6 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:29 5075/300000 https://directlyapply.com/jobs/freedom-forever/6122a5bbd530ded3b928791e CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:30 5076/300000 https://directlyapply.com/jobs/saic/613788a2a8cf4c3be7b99fe9 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:31 5077/300000 https://directlyapply.com/jobs/e-solutions/613788a2a8cf4c3be7b99feb CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:32 5078/300000 https://directlyapply.com/jobs/pacific-northwest-national-laboratory/613788a3a8cf4c3be7b99fed CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:33 5079/300000 https://directlyapply.com/jobs/bayada-home-health-care/613788a4a8cf4c3be7b99fef CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:33 5080/300000 https://directlyapply.com/jobs/techdigital-corporation/613788a5a8cf4c3be7b99ff1 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:34 5081/300000 https://directlyapply.com/jobs/paycom-online/613788a5a8cf4c3be7b99ff3 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:35 5082/300000 https://directlyapply.com/jobs/packback/60e2581212f8fac15b6b4059 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:35 5083/300000 https://directlyapply.com/jobs/ups/613788a7a8cf4c3be7b99ff5 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:36 5084/300000 https://directlyapply.com/jobs/saxon-global/613788a7a8cf4c3be7b99ff7 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:37 5085/300000 https://directlyapply.com/jobs/promedica-health-system/613788a8a8cf4c3be7b99ffa CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:37 5086/300000 https://directlyapply.com/jobs/zurich-na/613788a9a8cf4c3be7b99ffc CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:38 5087/300000 https://directlyapply.com/jobs/kforce/613788a9a8cf4c3be7b99ffd CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:39 5089/300000 https://directlyapply.com/jobs/the-estee-lauder-companies/613788aba8cf4c3be7b9a001 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:40 5090/300000 https://directlyapply.com/jobs/oreilly-automotive-stores/613788aba8cf4c3be7b9a003 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:42 5092/300000 https://directlyapply.com/jobs/linbar-solutions/613788ada8cf4c3be7b9a006 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:42 5093/300000 https://directlyapply.com/jobs/kforce-technology-staffing/613788aea8cf4c3be7b9a007 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:43 5094/300000 https://directlyapply.com/jobs/anthem/613788aea8cf4c3be7b9a009 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:43 Error 1062: Duplicate entry 'Full Stack Developer' for key 'SimularJobTitles.PRIMARY'",
		"2021/09/07 15:43:44 5095/300000 https://directlyapply.com/jobs/unavailable/613788afa8cf4c3be7b9a00c CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:45 5097/300000 https://directlyapply.com/jobs/volt/613788b1a8cf4c3be7b9a00f CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:46 5098/300000 https://directlyapply.com/jobs/shv/613788b1a8cf4c3be7b9a010 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:46 Error 1062: Duplicate entry 'Software Engineer' for key 'SimularJobTitles.PRIMARY'",
		"2021/09/07 15:43:47 5099/300000 https://directlyapply.com/jobs/jpmorgan-chase/613788b2a8cf4c3be7b9a013 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:47 5100/300000 https://directlyapply.com/jobs/general-dynamics-information-technology/613788b3a8cf4c3be7b9a015 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:48 Error 1062: Duplicate entry 'CDLA' for key 'SimularJobTitles.PRIMARY'",
		"2021/09/07 15:43:48 5101/300000 https://directlyapply.com/jobs/live-trucking/613788b3a8cf4c3be7b9a017 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:49 5102/300000 https://directlyapply.com/jobs/silgan-containers-corporation/613788b4a8cf4c3be7b9a018 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:49 5103/300000 https://directlyapply.com/jobs/gencare-staffing-solutions/613788b5a8cf4c3be7b9a01a CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:50 Error 1062: Duplicate entry 'Software Engineer' for key 'SimularJobTitles.PRIMARY'",
		"2021/09/07 15:43:50 5104/300000 https://directlyapply.com/jobs/eventbrite/613788b5a8cf4c3be7b9a01d CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:51 5105/300000 https://directlyapply.com/jobs/wyndham-vacation-ownership/613788b6a8cf4c3be7b9a01f CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:52 5106/300000 https://directlyapply.com/jobs/nielsen-holdings/613788b7a8cf4c3be7b9a020 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:52 5107/300000 https://directlyapply.com/jobs/pratt/613788b8a8cf4c3be7b9a022 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:53 Error 1062: Duplicate entry 'Software Engineer' for key 'SimularJobTitles.PRIMARY'",
		"2021/09/07 15:43:53 5108/300000 https://directlyapply.com/jobs/hired/613788b8a8cf4c3be7b9a025 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:54 5109/300000 https://directlyapply.com/jobs/botw/613788b9a8cf4c3be7b9a026 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:55 5110/300000 https://directlyapply.com/jobs/energizer-holdings/613788baa8cf4c3be7b9a029 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:56 5111/300000 https://directlyapply.com/jobs/grubhub-holdings/613788bba8cf4c3be7b9a02a CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:56 5112/300000 https://directlyapply.com/jobs/athletico/613788bba8cf4c3be7b9a02c CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:57 5113/300000 https://directlyapply.com/jobs/stratus/613788bca8cf4c3be7b9a02e CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:58 5114/300000 https://directlyapply.com/jobs/rapidsoft-corp/613788bda8cf4c3be7b9a031 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:59 5115/300000 https://directlyapply.com/jobs/roswell-toyota-scion/613788bea8cf4c3be7b9a033 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:43:59 5116/300000 https://directlyapply.com/jobs/je/613788bfa8cf4c3be7b9a035 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:01 5117/300000 https://directlyapply.com/jobs/bristol-myers-squibb/613788c0a8cf4c3be7b9a037 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:01 Error 1062: Duplicate entry 'Full Stack Developer' for key 'SimularJobTitles.PRIMARY'",
		"2021/09/07 15:44:01 5118/300000 https://directlyapply.com/jobs/axelon-services-corporation/613788c0a8cf4c3be7b9a038 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:02 5119/300000 https://directlyapply.com/jobs/roadrunner/613788c1a8cf4c3be7b9a03b CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:03 5120/300000 https://directlyapply.com/jobs/verizon/613788c2a8cf4c3be7b9a03c CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:03 5121/300000 https://directlyapply.com/jobs/deloitte/613788c3a8cf4c3be7b9a03f CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:04 5122/300000 https://directlyapply.com/jobs/general-dynamics/613788c4a8cf4c3be7b9a041 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:05 5123/300000 https://directlyapply.com/jobs/unavailable/613788c4a8cf4c3be7b9a043 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:06 5124/300000 https://directlyapply.com/jobs/engility-holdings/613788c5a8cf4c3be7b9a044 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:06 5125/300000 https://directlyapply.com/jobs/popular/613788c6a8cf4c3be7b9a047 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:07 5126/300000 https://directlyapply.com/jobs/community-home-care-and-hospice/613788c7a8cf4c3be7b9a049 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:08 5127/300000 https://directlyapply.com/jobs/cbiz/613788c7a8cf4c3be7b9a04b CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:09 5128/300000 https://directlyapply.com/jobs/ctg/613788c8a8cf4c3be7b9a04d CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:10 5129/300000 https://directlyapply.com/jobs/facebook/613788c9a8cf4c3be7b9a04f CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:10 Error 1062: Duplicate entry 'Software Engineer' for key 'SimularJobTitles.PRIMARY'",
		"2021/09/07 15:44:10 5130/300000 https://directlyapply.com/jobs/securecom-wireless/613788caa8cf4c3be7b9a050 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:11 5131/300000 https://directlyapply.com/jobs/capgemini/613788cba8cf4c3be7b9a053 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:12 5132/300000 https://directlyapply.com/jobs/general-dynamics-information-technology/613788cca8cf4c3be7b9a055 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:13 5133/300000 https://directlyapply.com/jobs/cvs-health/613788cca8cf4c3be7b9a057 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:14 5134/300000 https://directlyapply.com/jobs/randstad-us/613788cda8cf4c3be7b9a059 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:14 5135/300000 https://directlyapply.com/jobs/emory-healthcareemory-university/613788cea8cf4c3be7b9a05b CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:15 5137/300000 https://directlyapply.com/jobs/randstad-us/613788cfa8cf4c3be7b9a05e CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:16 5138/300000 https://directlyapply.com/jobs/fis/613788d0a8cf4c3be7b9a060 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:17 5139/300000 https://directlyapply.com/jobs/dominos/613788d0a8cf4c3be7b9a062 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:18 5140/300000 https://directlyapply.com/jobs/deloitte/613788d1a8cf4c3be7b9a064 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:19 5141/300000 https://directlyapply.com/jobs/commonwealth-financial-network/613788d2a8cf4c3be7b9a066 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:20 5142/300000 https://directlyapply.com/jobs/mindlance/613788d3a8cf4c3be7b9a067 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:20 Error 1062: Duplicate entry 'Full Stack Developer' for key 'SimularJobTitles.PRIMARY'",
		"2021/09/07 15:44:20 5143/300000 https://directlyapply.com/jobs/kforce/613788d3a8cf4c3be7b9a069 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:21 5144/300000 https://directlyapply.com/jobs/gila-river-health-care/613788d4a8cf4c3be7b9a06c CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:22 5145/300000 https://directlyapply.com/jobs/usa-truck/613788d5a8cf4c3be7b9a06d CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:22 5146/300000 https://directlyapply.com/jobs/maggianos-little-italy/613788d5a8cf4c3be7b9a06f CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:23 5148/300000 https://directlyapply.com/jobs/banfield-the-pet-hospital/613788d7a8cf4c3be7b9a073 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:24 5149/300000 https://directlyapply.com/jobs/did/613788d7a8cf4c3be7b9a075 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:26 5150/300000 https://directlyapply.com/jobs/unitedhealth-group/613788d8a8cf4c3be7b9a077 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:27 5151/300000 https://directlyapply.com/jobs/national-vision/613788daa8cf4c3be7b9a079 CPA: 0.000000 Responce: 200 OK",
		"2021/09/07 15:44:27 5152/300000 https://directlyapply.com/jobs/army-national-guard/613788daa8cf4c3be7b9a07b CPA: 0.000000 "
	)
	static func dummyFuntion() {
		print("error")
	}
	static var dummyDataShortLogs = [String](
		arrayLiteral: "silly log", "silly log 2", "Tom", "Tom", "Tom")
	static var previews: some View {
		LogsView(logs: dummyData.joined(separator: "\n"), refreashLogs: dummyFuntion, downloadLogs: dummyFuntion)
		LogsView(logs: dummyDataShortLogs.joined(separator: "\n"), refreashLogs: dummyFuntion, downloadLogs: dummyFuntion)
	}
}

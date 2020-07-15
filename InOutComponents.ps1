param (
   [string]$path = ""
)




$watch = [system.diagnostics.stopwatch]::StartNew()
$root ="component"
$rootName ="name"
$rootInputs ="inputs"
$rootOutputs ="outputs"
$rootAttr ="attr"


$data= @()
$collectionWithItems = New-Object System.Collections.ArrayList

Get-ChildItem $path -Recurse -Filter *component.ts | 
Foreach-Object {
    

    $arr= @{}
    $arr[$root]=@{}
    $arr[$root][$rootName] = $_.Name
    #inputs
    $arr[$root][$rootInputs] = @{}
    $arr[$root][$rootInputs][$rootAttr] = @()
    #$arr[$_.Name][$rootInputs]["arg"] = @()

    $arr[$root][$rootOutputs] = @{}
    $arr[$root][$rootOutputs][$rootAttr] = @()
    

    $componentName = $_.Name
    $content = Get-Content $_.FullName
    $currentPath = (Get-Item -Path $_.FullName)
    
    
    
   #get line position        
   $inpLineNumbers = (Select-String -Path $currentPath -Pattern '@Input()').LineNumber
   $outpLineNumbers = (Select-String -Path $currentPath -Pattern '@Output()').LineNumber
   
   

   $props = @()
   $arguments= @()   
   $outProps = @()
   $outArguments= @()

 

       if($inpLineNumbers.count -gt 0 )
       {
             #inputs
             Foreach ($inpLineNumber in $inpLineNumbers){

               #get property name and type of line + 1
               $info= (Get-Content -Path $currentPath -TotalCount  ($inpLineNumber + 1) )[-1]
               $splitterData = -split $info     
               $props += $splitterData[2] + $splitterData[3]
               
                        
             }
           
             #$rootOutputs
              Foreach ($outLineNumber in $outpLineNumbers){

               $info= (Get-Content -Path $currentPath -TotalCount  ($outLineNumber + 1) )[-1]
               $splitterData = -split $info     
               $outProps += $splitterData[2] + $splitterData[3]
         
             }



             #inputs
             $arr[$root][$rootInputs][$rootAttr] += $props | Foreach-Object { $_ } 
             $arr[$root][$rootOutputs][$rootAttr] += $outProps | Foreach-Object { $_ }
             
              
             $data += $arr
             Write-Host $_.Name "--- (done)" -ForegroundColor Yellow

         }
   }



$watch.Stop()
#customObject
$data | ForEach-Object {
                    $temp = "" | select $root, $rootInputs, $rootOutputs
                    $temp.component =  $_.component.name
                    $temp.inputs = $_.component.inputs.attr | ForEach-Object { $_  } 
                    $temp.outputs = $_.component.Outputs.attr | ForEach-Object { $_}
                    $collectionWithItems.Add($temp) | Out-Null
}



$collectionWithItems | ForEach-Object{

Write-Host "componentName": ($_.component)   -ForegroundColor Green
Write-Host "Inputs:" ($_.inputs | ForEach-Object { $_ + ";" }) -ForegroundColor Cyan
Write-Host "Outputs:" ($_.outputs | ForEach-Object { $_  + ";" }) -ForegroundColor Cyan
Write-Host "num of inputs": $_.inputs.count
Write-Host "num of outputs": $_.outputs.count
Write-Host "----"

}

Write-Host "num. of components searched:" ($collectionWithItems.Count) -ForegroundColor Yellow
Write-Host "Elapsed time process: " $watch.Elapsed -ForegroundColor Yellow

